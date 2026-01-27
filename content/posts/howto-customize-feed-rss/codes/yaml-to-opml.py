# Example usage:
# python3 content/posts/howto-customize-feed-rss/codes/yaml-to-opml.py data/rss/blogs.yaml -o blogs.opml --include-inactive

import argparse
import yaml
import xml.etree.ElementTree as ET
from xml.dom import minidom
from datetime import datetime
from pathlib import Path


def prettify(elem):
    rough_string = ET.tostring(elem, "utf-8")
    reparsed = minidom.parseString(rough_string)
    return reparsed.toprettyxml(indent="  ")


def yaml_to_opml(input_path: Path, output_path: Path, include_inactive: bool):
    with input_path.open("r", encoding="utf-8") as f:
        feeds = yaml.safe_load(f)

    opml = ET.Element("opml", version="1.0")

    head = ET.SubElement(opml, "head")
    ET.SubElement(head, "title").text = "RSS Feeds"
    ET.SubElement(head, "dateCreated").text = datetime.utcnow().isoformat()

    body = ET.SubElement(opml, "body")

    for feed in feeds:
        if not feed.get("feed"):
            # Explicit rule: no feed → skip
            continue

        if not feed.get("active", False) and not include_inactive:
            continue

        outline = ET.SubElement(
            body,
            "outline",
            text=feed["name"],
            title=feed["name"],
            type="rss",
            xmlUrl=feed["feed"],
            htmlUrl=feed.get("url", ""),
        )

        if feed.get("description"):
            outline.set("description", feed["description"])

        if not feed.get("active", False):
            outline.set("category", "inactive")

    output_path.write_text(prettify(opml), encoding="utf-8")


def main():
    parser = argparse.ArgumentParser(
        description="Convert a YAML RSS list to OPML"
    )
    parser.add_argument(
        "input",
        type=Path,
        help="Path to input YAML file",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        help="Path to output OPML file (default: same name as input)",
    )
    parser.add_argument(
        "--include-inactive",
        action="store_true",
        help="Include feeds marked as inactive",
    )

    args = parser.parse_args()

    if not args.input.exists():
        parser.error(f"Input file does not exist: {args.input}")

    output_path = args.output or args.input.with_suffix(".opml")

    yaml_to_opml(
        input_path=args.input,
        output_path=output_path,
        include_inactive=args.include_inactive,
    )

    print(f"✅ OPML written to {output_path}")


if __name__ == "__main__":
    main()
