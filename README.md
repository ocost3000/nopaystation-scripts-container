# nopaystation-scripts-container

A Docker image that bundles [sigmaboy/nopaystation_scripts](https://github.com/sigmaboy/nopaystation_scripts) and all its dependencies (pkg2zip, mktorrent, torrent7z) into a ready-to-use container. No local installation required.

## Pull the image

```bash
docker pull ghcr.io/ocost3000/nopaystation-scripts-container:latest
```

## Usage

All scripts are on the PATH inside the container. Mount a local directory to `/data` to access output files on your host:

```bash
docker run --rm -v /path/to/output:/data ghcr.io/ocost3000/nopaystation-scripts-container:latest <script> <args>
```

### nps_tsv.sh

Downloads every `.tsv` file from NoPayStation and creates a dated tar archive. The TSV files are required by most other scripts.

```bash
docker run --rm -v /path/to/output:/data \
  ghcr.io/ocost3000/nopaystation-scripts-container:latest \
  nps_tsv.sh /data
```

### nps_game.sh

Downloads a PS Vita game by title ID and places the `.7z` file in the output directory.

```bash
docker run --rm -v /path/to/output:/data \
  ghcr.io/ocost3000/nopaystation-scripts-container:latest \
  nps_game.sh /data/GAME.tsv PCSE00986
```

Title IDs can be looked up at [renascene.com/psv](http://renascene.com/psv/).

### nps_update.sh

Downloads the latest (or all) updates for a title ID into a `<TITLE_ID>_update` directory.

```bash
docker run --rm -v /path/to/output:/data \
  ghcr.io/ocost3000/nopaystation-scripts-container:latest \
  nps_update.sh [-a] PCSE00986
```

### nps_dlc.sh

Downloads every DLC with an available zRIF key for a title ID into a `<TITLE_ID>_dlc` directory.

```bash
docker run --rm -v /path/to/output:/data \
  ghcr.io/ocost3000/nopaystation-scripts-container:latest \
  nps_dlc.sh /data/DLC.tsv PCSE00986
```

### nps_psm.sh

Downloads a PSM game by title ID.

```bash
docker run --rm -v /path/to/output:/data \
  ghcr.io/ocost3000/nopaystation-scripts-container:latest \
  nps_psm.sh /data/PSM.tsv NPSA00115
```

### nps_psp.sh

Downloads a PSP game by title ID and places the `.iso` in the output directory.

```bash
docker run --rm -v /path/to/output:/data \
  ghcr.io/ocost3000/nopaystation-scripts-container:latest \
  nps_psp.sh /data/PSP_GAMES.tsv NPUZ00001
```

Title IDs can be looked up at [renascene.com/psp](http://renascene.com/psp/).

### nps_bundle.sh

Downloads the base game, all updates, and all DLC for a title ID. Optionally creates torrents with `-c`.

```bash
docker run --rm -v /path/to/output:/data \
  ghcr.io/ocost3000/nopaystation-scripts-container:latest \
  nps_bundle.sh [-a] -t PCSE00986 -d /data [-c "http://announce.url"] [<SOURCE FLAG>]
```

### nps_region.sh

Downloads all base games for a specific region (`US`, `JP`, `EU`, `ASIA`).

```bash
docker run --rm -v /path/to/output:/data \
  ghcr.io/ocost3000/nopaystation-scripts-container:latest \
  nps_region.sh -r ASIA -t game -d /data [-c http://announce.url] [-s <SOURCE>] [-a]
```

### pyNPU.py

Checks for updates and generates changelogs/download links for your games.

```bash
docker run --rm -v /path/to/output:/data \
  ghcr.io/ocost3000/nopaystation-scripts-container:latest \
  pyNPU.py -h
```

## Post scripts

`nps_bundle.sh` and `nps_region.sh` support post hooks (`nps_bundle_post.sh` / `nps_region_post.sh`). Place the executable script in your mounted volume directory and pass that directory as the working context — the container will pick it up automatically.

## Credits

All scripts are from [sigmaboy/nopaystation_scripts](https://github.com/sigmaboy/nopaystation_scripts). This repo only provides the Docker packaging.
