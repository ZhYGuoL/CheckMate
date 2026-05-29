#!/usr/bin/env python3
"""Download VC/accelerator logos into the app bundle."""

import json
import re
import time
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
JSON_PATH = ROOT / "CheckMate" / "vc_locations.json"
OUT_DIR = ROOT / "CheckMate" / "Resources" / "Logos"

DOMAINS = {
    "Y Combinator": "ycombinator.com",
    "Andreessen Horowitz": "a16z.com",
    "Sequoia Capital": "sequoiacap.com",
    "Kleiner Perkins": "kleinerperkins.com",
    "Accel": "accel.com",
    "Lightspeed Venture Partners": "lsvp.com",
    "Greylock Partners": "greylock.com",
    "Khosla Ventures": "khoslaventures.com",
    "Menlo Ventures": "menlovc.com",
    "New Enterprise Associates": "nea.com",
    "General Catalyst": "generalcatalyst.com",
    "Founders Fund": "foundersfund.com",
    "First Round Capital": "firstround.com",
    "Benchmark": "benchmark.com",
    "Index Ventures": "indexventures.com",
    "IVP": "ivp.com",
    "Redpoint Ventures": "redpoint.com",
    "Mayfield": "mayfield.com",
    "DCVC": "dcvc.com",
    "CRV": "crv.com",
    "Battery Ventures": "battery.com",
    "Canaan": "canaan.com",
    "Sierra Ventures": "sierraventures.com",
    "Felicis": "felicis.com",
    "Norwest Venture Partners": "nvp.com",
    "Sutter Hill Ventures": "shv.com",
    "U.S. Venture Partners": "usvp.com",
    "Trinity Ventures": "trinityventures.com",
    "Threshold Ventures": "threshold.vc",
    "Scale Venture Partners": "scalevp.com",
    "Sapphire Ventures": "sapphireventures.com",
    "Meritech Capital": "meritechcapital.com",
    "Ribbit Capital": "ribbitcap.com",
    "Uncork Capital": "uncorkcapital.com",
    "True Ventures": "trueventures.com",
    "Floodgate": "floodgate.com",
    "Foundation Capital": "foundationcapital.com",
    "Costanoa Ventures": "costanoa.vc",
    "Pear VC": "pear.vc",
    "Cowboy Ventures": "cowboy.vc",
    "Wing Venture Capital": "wing.vc",
    "Icon Ventures": "iconventures.com",
    "Playground Global": "playground.global",
    "S32": "s32.com",
    "GSR Ventures": "gsrventures.com",
    "DCM Ventures": "dcm.com",
    "Sofinnova Investments": "sofinnova.com",
    "TCV": "tcv.com",
    "Notable Capital": "notablecap.com",
    "Renegade Partners": "renegadepartners.com",
    "Owl Ventures": "owlvc.com",
    "Third Point Ventures": "thirdpointventures.com",
    "Merus Capital": "meruscap.com",
    "5AM Ventures": "5amventures.com",
    "The Westly Group": "westlygroup.com",
    "Nexus Venture Partners": "nexusvp.com",
    "Onset Ventures": "onset.com",
    "Altimeter Capital": "altimeter.com",
    "Shasta Ventures": "shastaventures.com",
    "Storm Ventures": "stormventures.com",
    "Altos Ventures": "altos.vc",
    "Morgenthaler Ventures": "morgenthaler.com",
    "TransLink Capital": "translinkcapital.com",
    "Ulu Ventures": "uluventures.com",
    "Plug and Play Ventures": "plugandplaytechcenter.com",
    "GV": "gv.com",
    "Gradient Ventures": "gradient.com",
    "Salesforce Ventures": "salesforce.com",
    "SV Angel": "svangel.com",
    "Forerunner Ventures": "forerunnerventures.com",
    "Homebrew": "homebrew.co",
    "Initialized Capital": "initialized.com",
    "Craft Ventures": "craftventures.com",
    "Slow Ventures": "slow.co",
    "Obvious Ventures": "obvious.com",
    "Base10 Partners": "base10.vc",
    "Bedrock Capital": "bedrockcap.com",
    "Bloomberg Beta": "bloombergbeta.com",
    "Bow Capital": "bowcapital.com",
    "Caffeinated Capital": "caffeinatedcapital.com",
    "Congruent Ventures": "congruentvc.com",
    "Crosslink Capital": "crosslinkcapital.com",
    "Fifty Years": "fiftyyears.com",
    "Flourish Ventures": "flourishventures.com",
    "Founders Circle Capital": "founderscircle.com",
    "Headline": "headline.com",
    "ICONIQ Capital": "iconiqcapital.com",
    "Jackson Square Ventures": "jsv.vc",
    "Lemnos Labs": "lemnoslabs.com",
    "Maven Ventures": "mavenventures.com",
    "Reach Capital": "reachcapital.com",
    "Ridge Ventures": "ridge.vc",
    "SignalFire": "signalfire.com",
    "South Park Commons": "southparkcommons.com",
    "Spearhead": "spearhead.co",
    "Susa Ventures": "susaventures.com",
    "Thomvest Ventures": "thomvest.com",
    "Top Tier Capital Partners": "ttcp.com",
    "Unusual Ventures": "unusual.vc",
    "Village Global": "villageglobal.vc",
    "Amplify Partners": "amplifypartners.com",
    "Afore Capital": "afore.vc",
    "Eclipse": "eclipse.vc",
    "11.2 Capital": "112capital.com",
    "AME Cloud Ventures": "amecloudventures.com",
    "Amino Capital": "aminocapital.com",
    "XYZ Venture Capital": "xyz.vc",
    "Race Capital": "race.capital",
    "Streamlined Ventures": "streamlined.vc",
    "MHS Capital": "mhscapital.com",
    "Cervin Ventures": "cervinventures.com",
    "Javelin Venture Partners": "javelinvp.com",
    "Signia Venture Partners": "signiaventures.com",
    "Emergence Capital": "emcap.com",
    "Webb Investment Network": "winfunding.com",
    "Zetta Venture Partners": "zettavp.com",
    "500 Global": "500.co",
    "Alchemist Accelerator": "alchemistaccelerator.com",
    "IndieBio": "indiebio.co",
    "SOSV": "sosv.com",
    "HAX": "hax.co",
    "Berkeley SkyDeck": "skydeck.berkeley.edu",
    "Stanford StartX": "startx.com",
    "Activate": "activate.org",
    "QB3": "qb3.org",
    "CITRIS Foundry": "citris.org",
    "The House Fund": "thehouse.fund",
    "Entrepreneurs Roundtable Accelerator SF": "eranyc.com",
    "Founder Institute": "fi.co",
    "Techstars San Francisco": "techstars.com",
    "Founders Space": "foundersspace.com",
    "Matter": "matter.vc",
    "Acceleprise San Francisco": "acceleprise.com",
    "Acario Innovation": "acario.com",
    "Activate Capital": "activatecap.com",
    "Artiman Ventures": "artiman.com",
    "August Capital": "augustcapital.com",
    "Avanta Ventures": "avantaventures.com",
    "Avid Ventures": "avidventures.com",
    "Azure Capital Partners": "azurecap.com",
    "Bain Capital Ventures": "baincapitalventures.com",
    "Blumberg Capital": "blumbergcapital.com",
    "BMW i Ventures": "bmwiventures.com",
    "Bosch Ventures": "rbvc.com",
    "Breakout Ventures": "breakout.vc",
    "Builders VC": "builders.vc",
    "Canvas Ventures": "canvas.vc",
    "Celesta Capital": "celesta.capital",
    "Clear Ventures": "clear.ventures",
    "Conductive Ventures": "conductive.vc",
    "Core Ventures Group": "coreventuresgroup.com",
    "Core Innovation Capital": "corevc.com",
    "Creative Ventures": "creativeventures.vc",
    "Defy Partners": "defy.vc",
    "E14 Fund": "e14fund.com",
    "Eniac Ventures": "eniac.vc",
    "Engineering Capital": "engineeringcapital.com",
    "Ensemble VC": "ensemble.vc",
    "Fin Capital": "fin.capital",
    "F-Prime Capital": "fprimecapital.com",
    "Fuel Capital": "fuelcapital.com",
    "Fusion Fund": "fusionfund.com",
    "Future Ventures": "future.ventures",
    "G2 Venture Partners": "g2vp.com",
    "Garage Technology Ventures": "garage.com",
    "Genacast Ventures": "genacast.com",
    "Genoa Ventures": "genoa.vc",
    "Glynn Capital": "glynncapital.com",
    "Golden Gate Ventures": "goldengate.vc",
    "Graphene Ventures": "graphenevc.com",
    "GreatPoint Ventures": "greatpointventures.com",
    "Green Bay Ventures": "greenbayventures.com",
    "Hanwha Asset Management": "hanwha.com",
    "Harrison Metal": "harrisonmetal.com",
    "Haystack": "haystack.vc",
    "HealthQuest Capital": "healthquestcapital.com",
    "Hustle Fund": "hustlefund.vc",
    "Industry Ventures": "industryventures.com",
    "JAZZ Venture Partners": "jazzvp.com",
    "Kapor Capital": "kaporcapital.com",
    "K9 Ventures": "k9ventures.com",
    "Liquid 2 Ventures": "liquid2.vc",
    "MaC Venture Capital": "macventurecapital.com",
    "Matrix Partners": "matrixpartners.com",
    "Maverick Ventures": "maverickventures.com",
    "Moderne Ventures": "moderneventures.com",
    "Munich Re Ventures": "munichre.com",
    "NFX": "nfx.com",
    "NewView Capital": "newviewcap.com",
    "Next47": "next47.com",
    "Novo Holdings": "novoholdings.dk",
    "NVIDIA Inception": "nvidia.com",
    "Precursor Ventures": "precursorvc.com",
    "Presidio Ventures": "presidio-ventures.com",
    "Quiet Capital": "quiet.com",
    "Refactor Capital": "refactor.com",
    "Rocketship.vc": "rocketship.vc",
    "Samsung Catalyst Fund": "samsung.com",
    "ServiceNow Ventures": "servicenow.com",
    "Toyota Ventures": "toyota.ventures",
}


def slugify(name: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "", name.lower())
    return slug or "firm"


def guess_domain(name: str) -> str:
    if name in DOMAINS:
        return DOMAINS[name]
    slug = slugify(name.replace(" Ventures", "").replace(" Capital", "").replace(" Partners", ""))
    return f"{slug}.com"


def download_logo(domain: str, destination: Path) -> bool:
    sources = [
        f"https://logo.clearbit.com/{domain}?size=128",
        f"https://www.google.com/s2/favicons?domain={domain}&sz=128",
    ]
    for url in sources:
        try:
            request = urllib.request.Request(url, headers={"User-Agent": "CheckMateLocal/1.0"})
            with urllib.request.urlopen(request, timeout=12) as response:
                data = response.read()
            if len(data) < 200:
                continue
            destination.write_bytes(data)
            return True
        except (urllib.error.HTTPError, urllib.error.URLError, TimeoutError):
            continue
    return False


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    records = json.loads(JSON_PATH.read_text())
    downloaded = 0
    missing = []

    for record in records:
        rank = record["rank"]
        name = record["name"]
        domain = guess_domain(name)
        destination = OUT_DIR / f"{rank}.png"
        if download_logo(domain, destination):
            downloaded += 1
            print(f"[{rank:03d}] {name} <- {domain}")
        else:
            missing.append(name)
            print(f"[{rank:03d}] {name} MISSING")
        time.sleep(0.15)

    print(f"\nDownloaded {downloaded}/{len(records)} logos")
    if missing:
        print(f"Missing ({len(missing)}): {', '.join(missing[:10])}{'...' if len(missing) > 10 else ''}")


if __name__ == "__main__":
    main()
