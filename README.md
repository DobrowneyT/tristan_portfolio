# tristan_portfolio

Tristan Dobrowney's portfolio, live at **https://tristan.dobrowney.com**.

A [Hugo](https://gohugo.io) site with its own small theme (no third-party theme).

| Path | What it is |
| --- | --- |
| `content/` | The words. `_index.md` is the home intro, `about/`, `resume.md`, and one folder per project in `projects/<slug>/index.md`. |
| `layouts/` | The theme: HTML templates (`baseof.html` wraps every page; `_partials/` are shared pieces). |
| `assets/css/main.css`, `assets/js/theme.js` | All styling, plus the light/dark toggle. |
| `data/resume.yaml` | The web résumé, transcribed from the master CV. |
| `static/` | Copied as-is: favicon and the résumé PDF. |
| `scripts/build-resume.sh` | Rebuilds the public résumé PDF from the master CV. |
| `hugo.toml` | Site settings: title, menu, contact links. |
| `deploy/` | nginx vhost and the site-sync auto-deploy timer (below). |
| `public/` | Hugo's output. Built on the VPS, never committed. |

**Light/dark:** the default follows the visitor's system setting (`prefers-color-scheme`). The toggle in the header saves an explicit choice in `localStorage`. Choosing the same theme as the system clears that choice, so the site goes back to following the system.

## Writing locally

Needs Hugo ≥ 0.158 (the standard edition is enough; extended isn't needed).

```bash
hugo server                 # http://localhost:1313, reloads on save
hugo --gc --minify          # one-off build into public/
```

### A project page

Each project is a page bundle: `content/projects/<slug>/index.md`, plus its images in the same folder. The front matter drives the card and the header:

```yaml
title: "TeaMate"
subtitle: "A robot arm that makes your tea"
date: 2025-03-01            # sorts nothing; shown on cards
period: "Winter 2025"       # shown on the page instead of the date
weight: 20                  # order on the home and projects pages (low = first)
status: stub                # stub = "write-up coming" badge + note; delete when the write-up is done
context: "Robotics project with Evan Evaniuk"
role: "Firmware: motion control, ..."
summary: "One or two sentences for the card."
stack: ["C++", "Arduino (MegaPi)"]
links:
  - { name: "GitHub", url: "https://github.com/..." }
video:                      # optional; see Videos
  src: "/media/teamate/demo.mp4"
  poster: "/media/teamate/poster.jpg"
  youtube: "https://youtu.be/..."
  caption: "First full brew"
```

- **Cover image:** drop `cover.jpg` (or `.png`/`.webp`) into the project folder. Hugo resizes it for the cards and the page. Until it exists, a striped "photo coming soon" placeholder shows instead.
- **Other images:** put them in the same folder and use `![Alt text](board.jpg)` in the Markdown.
- **Write-ups:** use `##` headings. A table of contents appears automatically once a non-stub post passes about 600 words.
- **About photo:** `content/about/portrait.jpg`, cropped to 4:5 automatically.

### Videos

Videos are **not** in git. They live on the VPS in `/srv/media/tristan/<project>/` and nginx serves them at `/media/…`. Pages use a plain `<video>` tag with no YouTube embed, so there's no tracking. The YouTube link is shown underneath as a fallback.

```bash
# 1. on your machine: download the original from YouTube Studio, then compress
ffmpeg -i original.mp4 -c:v libx264 -crf 26 -preset slow -vf "scale='min(1280,iw)':-2" \
       -c:a aac -b:a 128k -movflags +faststart demo.mp4
ffmpeg -ss 5 -i demo.mp4 -frames:v 1 -q:v 3 poster.jpg      # still frame at 5 s
# 2. upload
ssh ubuntu@51.68.212.98 mkdir -p /srv/media/tristan/teamate
scp demo.mp4 poster.jpg ubuntu@51.68.212.98:/srv/media/tristan/teamate/
# 3. set video.src and video.poster in the project's front matter and push
```

### Résumé

There is one source, the master CV at `~/Documents/Jobs/ai-job-search/documents/cv/main.tex`. After editing it:

```bash
scripts/build-resume.sh     # rebuilds static/resume/Tristan-Dobrowney-Resume.pdf
```

The public PDF has the phone number removed and the email swapped to `tristan@dobrowney.com`. The script refuses to publish if a phone number survives. The web version, `data/resume.yaml`, is a hand transcription: the script prints a reminder when the master changed since the last build. Commit both.

## Deploying

Push to `main`. Within about 5 minutes site-sync on the VPS pulls the clone and runs `hugo`, which rebuilds `public/`. nginx serves it with no restart. If the build fails, Hugo normally leaves the previous `public/` in place, so the old site stays up, and the build is retried every 5 minutes. See `journalctl -u site-sync`.

## site-sync: auto-deploy for *.dobrowney.com

One systemd timer on the VPS (`51.68.212.98`). Every 5 minutes, for each line of `/etc/site-sync/repos.list`, it:

1. **Pulls**: `git fetch` plus a fast-forward of the branch the clone has checked out (keep production clones on `main`). Git runs as the clone's owner (`ubuntu`), never root. A clone with local commits or edits is reported and left alone, never reset.
2. **Deploys**, but only for lines that name a deploy command, and only when HEAD differs from the last *successful* deploy. A failed deploy is retried on the next run. The command runs as root in the clone with `SUDO_USER=ubuntu`, exactly like typing `sudo <command>` there.

| Line in `repos.list` | Site | On a new commit |
| --- | --- | --- |
| `/srv/sites/tristan_portfolio  runuser -u "$SUDO_USER" -- … hugo …` | tristan.dobrowney.com | pull, then `hugo` builds `public/` (run as `ubuntu`, not root) |
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

### 5. Hugo, media folder, and the build step

For a fresh server, do this before step 4. If you're switching the live site from the plain placeholder to Hugo, follow the steps in this order. That way the placeholder stays up until the first Hugo build succeeds.

```bash
# a) Install Hugo, pinned. Ubuntu's apt package is too old for this site (needs >= 0.158).
dpkg --print-architecture          # expect amd64; otherwise pick the matching .deb
V=0.170.1
cd /tmp
wget -q https://github.com/gohugoio/hugo/releases/download/v$V/hugo_${V}_linux-amd64.deb \
        https://github.com/gohugoio/hugo/releases/download/v$V/hugo_${V}_checksums.txt
grep " hugo_${V}_linux-amd64.deb$" hugo_${V}_checksums.txt | sha256sum -c    # must print OK
sudo apt install ./hugo_${V}_linux-amd64.deb
hugo version

# b) Folder for self-hosted videos (served at /media/)
sudo install -d -o ubuntu -g ubuntu -m 755 /srv/media /srv/media/tristan

# c) Give the tristan_portfolio line its build command. The `[ -f hugo.toml ]`
#    guard matters: run on the placeholder checkout, a bare `hugo` would "succeed"
#    with an empty site and wipe public/. With the guard, the deploy fails
#    harmlessly (logged as FAILED and retried every 5 minutes) and the
#    placeholder keeps being served until the Hugo version reaches main.
sudo sed -i 's|^/srv/sites/tristan_portfolio$|/srv/sites/tristan_portfolio      [ -f hugo.toml ] \&\& runuser -u "$SUDO_USER" -- env HOME="/home/$SUDO_USER" hugo --gc --minify --cleanDestinationDir|' /etc/site-sync/repos.list
cat /etc/site-sync/repos.list

# d) Merge the Hugo branch to main (on your machine, or ask Claude), then on the VPS:
sudo systemctl start site-sync && journalctl -u site-sync -n 20
#    expect: tristan_portfolio: main … -> …, then "deploying", then "deployed"
ls /srv/sites/tristan_portfolio/public/index.html

# e) Install the updated vhost (adds /media/, the 404 page, and long caching for hashed CSS/JS)
sudo cp /srv/sites/tristan_portfolio/deploy/nginx/tristan.dobrowney.com.conf /etc/nginx/sites-available/tristan.dobrowney.com
sudo nginx -t && sudo systemctl reload nginx
curl -sI https://tristan.dobrowney.com/resume/ | head -1        # HTTP/2 200
curl -s  https://tristan.dobrowney.com/nope | grep -o 'Page not found'
```

The build runs as `ubuntu` (`runuser`), so `public/` and Hugo's caches belong to `ubuntu` like the rest of the clone. To upgrade Hugo later, repeat (a) with a new `V`.

## Adding another *.dobrowney.com project later

1. Clone it (`/srv/sites/<repo>` for a static site; anywhere for an app), on `main`, owned by `ubuntu`.
2. Add a line to `/etc/site-sync/repos.list`, with a deploy command if pulling alone is not enough. Mirror it in `deploy/site-sync/repos.list` here so the record stays in git.
3. Static site: certificate + vhost as in step 3. A Hugo site also needs a build command like the tristan_portfolio line.

No systemd change is needed: the list is read on every run.

## 2027: retiring the torn projects

Nothing here depends on them. Delete their lines from `crontab -e` (torn-dashboard, dashboard-dev, mug-bot ×2, torn-armoury, choonbot and the docker-prune line) and stop their containers. site-sync keeps running on its own.
