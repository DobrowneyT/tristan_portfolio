# tristan_portfolio

Tristan Dobrowney's portfolio, live at **https://tristan.dobrowney.com**.

- `public/`: the website (plain static files). This folder is the nginx web root, and nothing outside it is served.
- `deploy/nginx/tristan.dobrowney.com.conf`: the nginx vhost.
- `deploy/site-sync/`: the auto-deploy timer for **every `*.dobrowney.com` project on the VPS** (this site, `elena_portfolio` and `kidnet`). This repo is where it is kept.

## Deploying

Push to `main`. Within about 5 minutes the VPS fast-forwards its clone and nginx is serving the new files. There is no build step and no restart.

Local preview: `python3 -m http.server -d public 8000`, then open http://localhost:8000.

## site-sync: auto-deploy for *.dobrowney.com

One systemd timer on the VPS (`51.68.212.98`). Every 5 minutes, for each line of `/etc/site-sync/repos.list`, it:

1. **Pulls**: `git fetch` plus a fast-forward of the branch the clone has checked out (keep production clones on `main`). Git runs as the clone's owner (`ubuntu`), never root. A clone with local commits or edits is reported and left alone, never reset.
2. **Deploys**, but only for lines that name a deploy command, and only when HEAD differs from the last *successful* deploy. A failed deploy is retried on the next run. The command runs as root in the clone with `SUDO_USER=ubuntu`, exactly like typing `sudo <command>` there.

| Line in `repos.list` | Site | On a new commit |
| --- | --- | --- |
| `/srv/sites/tristan_portfolio` | tristan.dobrowney.com | pull only: nginx serves `public/` straight from the clone |
| `/srv/sites/elena_portfolio` | elena.dobrowney.com | pull only |
| `/home/ubuntu/kidnet  server/install.sh` | kidnet.dobrowney.com | pull, then `server/install.sh` (rebuild dashboard, update API, self-test) |

```
GitHub main ──every 5 min──▶ git fetch + ff-only (as ubuntu) ──changed?──▶ deploy command (as root), if any
```

The timer replaces the `*/5 … update.sh --if-changed` cron pattern used by the torn projects, and those cron lines are not affected. Output goes to the journal instead of a `deploy.log`:

```bash
journalctl -u site-sync -n 30           # what recent runs pulled/deployed
journalctl -u site-sync -f              # follow live
sudo systemctl start site-sync          # run right now instead of waiting
systemctl list-timers site-sync.timer   # when it runs next
systemctl status site-sync              # "failed" if the last run had any error
```

Security note: the service runs as root because `kidnet/server/install.sh` installs packages, units and nginx config. Anyone who can push to `main` of a repo that has a deploy command can therefore run code as root on the VPS. That is the same trust as running `sudo server/install.sh` by hand after every pull.

DNS needs no change: the wildcard `*` A record on dobrowney.com already points every subdomain at the VPS. The portfolio repos are public, so the clones pull over HTTPS without credentials. Kidnet's existing clone keeps whatever remote it already uses.

## One-time VPS setup

Run as `ubuntu` on the VPS, in this order.

### 1. Clone the portfolios

```bash
sudo install -d -o ubuntu -g ubuntu -m 755 /srv/sites
git clone https://github.com/DobrowneyT/tristan_portfolio.git /srv/sites/tristan_portfolio
git clone https://github.com/DobrowneyT/elena_portfolio.git  /srv/sites/elena_portfolio
```

`/srv/sites` rather than `~` because nginx (`www-data`) cannot read `/home/ubuntu`, which is mode 750 on Ubuntu 24.04.

### 2. Get kidnet onto main

site-sync deploys whatever branch the clone is on, so:

```bash
cd ~/kidnet && git status    # must be clean, with no local edits
git switch main && git pull --ff-only
```

### 3. nginx + TLS for each portfolio

Get the certificate first, because the vhost refers to its files:

```bash
for s in tristan elena; do
  sudo certbot certonly --nginx --cert-name $s.dobrowney.com -d $s.dobrowney.com
  sudo cp /srv/sites/${s}_portfolio/deploy/nginx/$s.dobrowney.com.conf /etc/nginx/sites-available/$s.dobrowney.com
  sudo ln -sf /etc/nginx/sites-available/$s.dobrowney.com /etc/nginx/sites-enabled/
done
sudo nginx -t && sudo systemctl reload nginx
curl -sI https://tristan.dobrowney.com | head -1   # HTTP/2 200
curl -sI https://elena.dobrowney.com   | head -1   # HTTP/2 200
```

Kidnet's vhost is managed by its own `install.sh`, so leave it alone.

### 4. Install site-sync

```bash
cd /srv/sites/tristan_portfolio/deploy/site-sync
sudo install -m 755 site-sync.sh /usr/local/bin/site-sync
sudo install -D -m 644 repos.list /etc/site-sync/repos.list
sudo install -m 644 site-sync.service site-sync.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now site-sync.timer

sudo systemctl start site-sync && journalctl -u site-sync -n 30
```

The **first run deploys kidnet once**: it has no "last deployed" marker yet, so `server/install.sh` runs even though nothing changed. That's harmless, because install.sh is idempotent and self-tests through nginx. Expect `kidnet: deployed <sha>` in the journal. Later runs only deploy kidnet when `main` moves.

The script, list and units are installed copies. After changing them in `deploy/site-sync/`, re-run the matching `install` line (and `daemon-reload` for units). The timer does not update itself.

## Adding another *.dobrowney.com project later

1. Clone it (`/srv/sites/<repo>` for a static site; anywhere for an app), on `main`, owned by `ubuntu`.
2. Add a line to `/etc/site-sync/repos.list`, with a deploy command if pulling alone is not enough. Mirror it in `deploy/site-sync/repos.list` here so the record stays in git.
3. Static site: certificate + vhost as in step 3.

No systemd change is needed: the list is read on every run.

## 2027: retiring the torn projects

Nothing here depends on them. Delete their lines from `crontab -e` (torn-dashboard, dashboard-dev, mug-bot ×2, torn-armoury, choonbot and the docker-prune line) and stop their containers. site-sync keeps running on its own.
