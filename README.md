# tristan_portfolio

Tristan Dobrowney's portfolio, live at **https://tristan.dobrowney.com**.

- `public/`: the website (plain static files). This folder is the nginx web root, and nothing outside it is served.
- `deploy/nginx/tristan.dobrowney.com.conf`: the nginx vhost.
- `deploy/site-sync/`: the shared auto-deploy timer. It pulls **this repo and every other site repo listed in `/etc/site-sync/repos.list`** (currently also `elena_portfolio`).

## Deploying

Push to `main`. Within about 5 minutes the VPS fast-forwards its clone and nginx is serving the new files. There is no build step and no restart.

```bash
journalctl -u site-sync -n 20        # on the VPS: what the last runs pulled
sudo systemctl start site-sync       # on the VPS: pull right now
```

Local preview: `python3 -m http.server -d public 8000`, then open http://localhost:8000.

## How it fits together on the VPS (51.68.212.98)

```
GitHub (main) ──every 5 min, git fetch + ff-only──▶ /srv/sites/<repo>        (owned by user sitesync)
                                                     └─ public/  ◀── nginx root for <name>.dobrowney.com
```

DNS needs no change: the wildcard `*` A record on dobrowney.com already points every subdomain at the VPS.

The clones use HTTPS, so the GitHub repos must be **public** for the server to pull them without credentials. A private repo would need a read-only deploy key for the `sitesync` user.

## One-time VPS setup

Run as your normal sudo user on the VPS.

### 1. site-sync (once for all sites)

```bash
sudo useradd --system --home-dir /srv/sites --shell /usr/sbin/nologin sitesync
sudo install -d -o sitesync -g sitesync -m 755 /srv/sites

# clone each site as sitesync
sudo -u sitesync git clone https://github.com/DobrowneyT/tristan_portfolio.git /srv/sites/tristan_portfolio
sudo -u sitesync git clone https://github.com/DobrowneyT/elena_portfolio.git  /srv/sites/elena_portfolio

# install the script, the list and the units from this repo's clone
cd /srv/sites/tristan_portfolio/deploy/site-sync
sudo install -m 755 site-sync.sh /usr/local/bin/site-sync
sudo install -d /etc/site-sync
sudo install -m 644 repos.list /etc/site-sync/repos.list
sudo install -m 644 site-sync.service site-sync.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now site-sync.timer

sudo systemctl start site-sync && journalctl -u site-sync -n 5   # test run
systemctl list-timers site-sync.timer                              # next run
```

The script and units are installed copies: if you change them in `deploy/site-sync/`, re-run the matching `install` line. The timer does not update itself.

### 2. nginx + TLS (once per site)

Get the certificate first, because the vhost refers to its files:

```bash
sudo certbot certonly --nginx --cert-name tristan.dobrowney.com -d tristan.dobrowney.com
sudo cp /srv/sites/tristan_portfolio/deploy/nginx/tristan.dobrowney.com.conf /etc/nginx/sites-available/tristan.dobrowney.com
sudo ln -s /etc/nginx/sites-available/tristan.dobrowney.com /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
curl -sI https://tristan.dobrowney.com | head -1     # HTTP/2 200
```

Repeat with `elena` for Elena's site (its conf is in the `elena_portfolio` repo).

nginx (`www-data`) needs to read the clone. `/srv/sites` and git checkouts are world-readable by default (755/644), so this works out of the box.

### Adding another site later

1. Clone it into `/srv/sites/<repo>` as `sitesync` (`sudo -u sitesync git clone …`).
2. Add `/srv/sites/<repo>` to `/etc/site-sync/repos.list` (and to `deploy/site-sync/repos.list` here so the record stays in git).
3. Get a certificate and install a vhost as in step 2.

No systemd change is needed: the timer reads the list on every run.
