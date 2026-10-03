"""Generate original document acceptance sources; inspect converted fixtures.

No dependencies, subprocesses, services, downloads, or skill runtime installation.
Outputs are exclusive creations. Native conversion and rendering are separate,
explicitly scoped foreground operations. This is not a production document editor.
"""

import argparse
import json
import posixpath
import struct
import zlib
from pathlib import Path
from xml.etree import ElementTree as ET
from zipfile import ZIP_DEFLATED, ZIP_STORED, ZipFile

NS = {
    "office": "urn:oasis:names:tc:opendocument:xmlns:office:1.0",
    "text": "urn:oasis:names:tc:opendocument:xmlns:text:1.0",
    "style": "urn:oasis:names:tc:opendocument:xmlns:style:1.0",
    "table": "urn:oasis:names:tc:opendocument:xmlns:table:1.0",
    "draw": "urn:oasis:names:tc:opendocument:xmlns:drawing:1.0",
    "fo": "urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0",
    "svg": "urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0",
    "xlink": "http://www.w3.org/1999/xlink",
    "presentation": "urn:oasis:names:tc:opendocument:xmlns:presentation:1.0",
    "chart": "urn:oasis:names:tc:opendocument:xmlns:chart:1.0",
    "dc": "http://purl.org/dc/elements/1.1/",
    "of": "urn:oasis:names:tc:opendocument:xmlns:of:1.2",
}
DECL = " ".join(f'xmlns:{key}="{value}"' for key, value in NS.items())


def png():
    def chunk(kind, data):
        return (
            struct.pack(">I", len(data))
            + kind
            + data
            + struct.pack(">I", zlib.crc32(kind + data))
        )

    pixels = b"".join(
        b"\0"
        + b"".join(
            bytes((30, 90, 160) if x < 60 else (240, 170, 40)) for x in range(120)
        )
        for _ in range(60)
    )
    return (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", struct.pack(">IIBBBBB", 120, 60, 8, 2, 0, 0, 0))
        + chunk(b"IDAT", zlib.compress(pixels))
        + chunk(b"IEND", b"")
    )


def document(body, automatic=""):
    return (
        f'<office:document-content {DECL} office:version="1.3">'
        f"<office:automatic-styles>{automatic}</office:automatic-styles>"
        f"<office:body>{body}</office:body></office:document-content>"
    )


def odf(path, kind, body, automatic="", styles="", extras=None):
    mime = f"application/vnd.oasis.opendocument.{kind}"
    files = {
        "content.xml": document(body, automatic),
        "styles.xml": f'<office:document-styles {DECL} office:version="1.3">{styles}</office:document-styles>',
        "Pictures/fixture.png": png(),
        **(extras or {}),
    }
    entries = (
        f'<manifest:file-entry manifest:full-path="/" manifest:media-type="{mime}"/>'
    )
    for name in files:
        media = "image/png" if name.endswith(".png") else "text/xml"
        entries += f'<manifest:file-entry manifest:full-path="{name}" manifest:media-type="{media}"/>'
    if extras:
        entries += '<manifest:file-entry manifest:full-path="Object1/" manifest:media-type="application/vnd.oasis.opendocument.chart"/>'
    files["META-INF/manifest.xml"] = (
        '<manifest:manifest xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0" manifest:version="1.3">'
        + entries
        + "</manifest:manifest>"
    )
    with path.open("xb") as stream, ZipFile(stream, "w") as package:
        package.writestr("mimetype", mime, compress_type=ZIP_STORED)
        for name, value in files.items():
            package.writestr(name, value, compress_type=ZIP_DEFLATED)


def pdf(path, objects):
    data = bytearray(b"%PDF-1.4\n%\xe2\xe3\xcf\xd3\n")
    offsets = [0]
    for number, obj in enumerate(objects, 1):
        offsets.append(len(data))
        data.extend(f"{number} 0 obj\n".encode() + obj + b"\nendobj\n")
    xref = len(data)
    data.extend(f"xref\n0 {len(offsets)}\n0000000000 65535 f \n".encode())
    for offset in offsets[1:]:
        data.extend(f"{offset:010d} 00000 n \n".encode())
    data.extend(
        f"trailer\n<< /Size {len(offsets)} /Root 1 0 R >>\nstartxref\n{xref}\n%%EOF\n".encode()
    )
    with path.open("xb") as output:
        output.write(data)


def pdf_stream(content, attributes=b""):
    return (
        b"<< /Length "
        + str(len(content)).encode()
        + b" "
        + attributes
        + b">>\nstream\n"
        + content
        + b"\nendstream"
    )


def sources(root):
    root.mkdir(parents=True, exist_ok=False)
    styles = """
    <office:styles><style:style style:name="Heading1" style:family="paragraph">
    <style:text-properties fo:font-size="20pt" fo:font-weight="bold"/></style:style></office:styles>
    <office:automatic-styles><style:page-layout style:name="Letter"><style:page-layout-properties
    fo:page-width="8.5in" fo:page-height="11in" fo:margin="0.75in"/></style:page-layout></office:automatic-styles>
    <office:master-styles><style:master-page style:name="Standard" style:page-layout-name="Letter">
    <style:header><text:p>Preserved header</text:p></style:header>
    <style:footer><text:p>Preserved footer</text:p></style:footer></style:master-page></office:master-styles>
    """
    body = """
    <office:text><text:h text:style-name="Heading1" text:outline-level="1">Preservation fixture</text:h>
    <text:p>Target paragraph before edit.</text:p>
    <text:p><office:annotation><dc:creator>Fixture author</dc:creator><text:p>Preserve this comment.</text:p></office:annotation>Unrelated paragraph.</text:p>
    <table:table table:name="KeepTable"><table:table-column table:number-columns-repeated="2"/>
    <table:table-row><table:table-cell office:value-type="string"><text:p>Label</text:p></table:table-cell>
    <table:table-cell office:value-type="string"><text:p>Value</text:p></table:table-cell></table:table-row>
    <table:table-row><table:table-cell office:value-type="string"><text:p>Keep</text:p></table:table-cell>
    <table:table-cell office:value-type="string"><text:p>42</text:p></table:table-cell></table:table-row></table:table>
    <text:p><draw:frame draw:name="KeepImage" text:anchor-type="as-char" svg:width="2in" svg:height="1in">
    <draw:image xlink:href="Pictures/fixture.png" xlink:type="simple" xlink:show="embed"/></draw:frame></text:p>
    <text:p>Figure 1. Preserve image and caption.</text:p><text:p text:style-name="NextPage">Second page retained.</text:p></office:text>
    """
    automatic = '<style:style style:name="NextPage" style:family="paragraph"><style:paragraph-properties fo:break-before="page"/></style:style>'
    odf(root / "preservation.odt", "text", body, automatic, styles)

    chart = document("""
    <office:chart><chart:chart chart:class="chart:bar" svg:width="4in" svg:height="2in">
    <chart:plot-area table:cell-range-address="Data.A1:B3" chart:data-source-has-labels="both">
    <chart:axis chart:dimension="x" chart:name="primary-x"/><chart:axis chart:dimension="y" chart:name="primary-y"/>
    <chart:series chart:values-cell-range-address="Data.B2:B3" chart:label-cell-address="Data.B1" chart:class="chart:bar"/>
    </chart:plot-area><table:table table:name="local-table"><table:table-row>
    <table:table-cell office:value-type="string"><text:p>Item</text:p></table:table-cell><table:table-cell office:value-type="string"><text:p>Value</text:p></table:table-cell></table:table-row>
    <table:table-row><table:table-cell office:value-type="string"><text:p>A</text:p></table:table-cell><table:table-cell office:value-type="float" office:value="10"><text:p>10</text:p></table:table-cell></table:table-row>
    <table:table-row><table:table-cell office:value-type="string"><text:p>B</text:p></table:table-cell><table:table-cell office:value-type="float" office:value="20"><text:p>20</text:p></table:table-cell></table:table-row>
    </table:table></chart:chart></office:chart>""")
    body = """
    <office:spreadsheet><table:named-expressions><table:named-range table:name="Inputs" table:base-cell-address="$Data.$A$1" table:cell-range-address="$Data.$B$2:.$B$3"/></table:named-expressions>
    <table:table table:name="Data"><table:table-column table:number-columns-repeated="2"/>
    <table:table-row><table:table-cell office:value-type="string"><text:p>Item</text:p></table:table-cell><table:table-cell office:value-type="string"><text:p>Value</text:p></table:table-cell></table:table-row>
    <table:table-row><table:table-cell office:value-type="string"><text:p>A</text:p></table:table-cell><table:table-cell table:style-name="Currency" office:value-type="float" office:value="10"><text:p>10</text:p></table:table-cell></table:table-row>
    <table:table-row><table:table-cell office:value-type="string"><text:p>B</text:p></table:table-cell><table:table-cell table:style-name="Currency" office:value-type="float" office:value="20"><text:p>20</text:p></table:table-cell></table:table-row>
    <table:shapes><draw:frame draw:name="KeepChart" svg:x="2in" svg:y="0.5in" svg:width="3in" svg:height="2in"><draw:object xlink:href="./Object1" xlink:type="simple"/></draw:frame></table:shapes></table:table>
    <table:table table:name="Summary"><table:table-row><table:table-cell office:value-type="string"><text:p>Total</text:p></table:table-cell>
    <table:table-cell table:formula="of:=SUM([Data.B2:Data.B3])" office:value-type="float" office:value="30"><text:p>30</text:p></table:table-cell></table:table-row></table:table>
    </office:spreadsheet>"""
    automatic = """
    <number:currency-style xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0" style:name="Money"><number:currency-symbol>$</number:currency-symbol><number:number number:decimal-places="2" number:min-integer-digits="1"/></number:currency-style>
    <style:style style:name="Highlight" style:family="table-cell" style:data-style-name="Money"><style:table-cell-properties fo:background-color="#fff2cc"/></style:style>
    <style:style style:name="Currency" style:family="table-cell" style:data-style-name="Money"><style:map style:condition="cell-content()&gt;15" style:apply-style-name="Highlight"/></style:style>"""
    odf(
        root / "formulas.ods",
        "spreadsheet",
        body,
        automatic,
        extras={"Object1/content.xml": chart},
    )

    styles = """
    <office:styles><style:style style:name="BlueMaster" style:family="drawing-page"><style:drawing-page-properties draw:fill="solid" draw:fill-color="#dce8f5"/></style:style></office:styles>
    <office:automatic-styles><style:page-layout style:name="Wide"><style:page-layout-properties fo:page-width="10in" fo:page-height="5.625in" style:print-orientation="landscape"/></style:page-layout></office:automatic-styles>
    <office:master-styles><style:master-page style:name="FixtureMaster" style:page-layout-name="Wide" draw:style-name="BlueMaster"/></office:master-styles>"""
    body = """
    <office:presentation><draw:page draw:name="KeepSlide" draw:master-page-name="FixtureMaster">
    <draw:frame draw:name="TargetText" svg:x="0.6in" svg:y="0.5in" svg:width="8in" svg:height="1in"><draw:text-box><text:p>Target slide before edit.</text:p></draw:text-box></draw:frame>
    <draw:frame draw:name="KeepImage" svg:x="0.6in" svg:y="2in" svg:width="3in" svg:height="1.5in"><draw:image xlink:href="Pictures/fixture.png" xlink:type="simple" xlink:show="embed"/></draw:frame>
    <presentation:notes><draw:frame presentation:class="notes" svg:x="1in" svg:y="1in" svg:width="6in" svg:height="3in"><draw:text-box><text:p>Preserve speaker note.</text:p></draw:text-box></draw:frame></presentation:notes>
    </draw:page></office:presentation>"""
    odf(root / "master-layout.odp", "presentation", body, styles=styles)

    pages = []
    for label in ("Known text on page one.", "Known text on page two."):
        pages.append(pdf_stream(f"BT /F1 18 Tf 72 700 Td ({label}) Tj ET".encode()))
    pdf(
        root / "text.pdf",
        [
            b"<< /Type /Catalog /Pages 2 0 R >>",
            b"<< /Type /Pages /Kids [3 0 R 4 0 R] /Count 2 >>",
            b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Resources << /Font << /F1 5 0 R >> >> /Contents 6 0 R >>",
            b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Resources << /Font << /F1 5 0 R >> >> /Contents 7 0 R >>",
            b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>",
            *pages,
        ],
    )
    (root / "source.md").write_text(
        "# Keep heading\n\nTarget text before edit.\n\n| Keep | Value |\n| --- | --- |\n| A | 42 |\n\n```text\nKeep code\n```\n",
        encoding="utf-8",
    )
    (root / "source.html").write_text(
        '<!doctype html><html lang="en"><meta charset="utf-8"><title>Fixture</title><body><h1>Keep heading</h1><p>Target text before edit.</p><table><tr><td>Keep</td><td>42</td></tr></table></body></html>',
        encoding="utf-8",
    )
    print(
        json.dumps(
            {"sources": str(root), "files": sorted(p.name for p in root.iterdir())}
        )
    )


def inspect(root):
    namespaces = {
        "w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
        "s": "http://schemas.openxmlformats.org/spreadsheetml/2006/main",
        "p": "http://schemas.openxmlformats.org/presentationml/2006/main",
    }
    results = {}
    for filename in ("preservation.docx", "formulas.xlsx", "master-layout.pptx"):
        with ZipFile(root / filename) as archive:
            names = set(archive.namelist())
            assert archive.testzip() is None, filename
            parts = {
                n: ET.fromstring(archive.read(n))
                for n in names
                if n.endswith((".xml", ".rels"))
            }
            for name, tree in parts.items():
                if not name.endswith(".rels"):
                    continue
                base = "" if name == "_rels/.rels" else name.split("/_rels/")[0]
                for rel in tree:
                    if rel.get("TargetMode") == "External":
                        continue
                    target = rel.attrib["Target"].split("#")[0]
                    target = (
                        target.lstrip("/")
                        if target.startswith("/")
                        else posixpath.normpath(posixpath.join(base, target))
                    )
                    assert target in names, (filename, name, target)
            if filename.endswith("docx"):
                tree = parts["word/document.xml"]
                assert tree.find(".//w:tbl", namespaces) is not None
                assert tree.find(".//w:drawing", namespaces) is not None
                assert any("header" in n for n in names) and any(
                    "footer" in n for n in names
                )
                assert "word/comments.xml" in names
                assert (
                    "Target paragraph before edit."
                    in archive.read("word/document.xml").decode()
                )
            elif filename.endswith("xlsx"):
                formulas = [
                    e.text
                    for t in parts.values()
                    for e in t.findall(".//s:f", namespaces)
                ]
                assert any("Data" in (f or "") for f in formulas), formulas
                assert (
                    parts["xl/workbook.xml"].find(".//s:definedName", namespaces)
                    is not None
                )
                assert any(n.startswith("xl/charts/chart") for n in names)
                assert any(
                    t.find(".//s:conditionalFormatting", namespaces) is not None
                    for t in parts.values()
                )
            else:
                assert any(n.startswith("ppt/slideMasters/slideMaster") for n in names)
                assert any(n.startswith("ppt/slideLayouts/slideLayout") for n in names)
                assert any(n.startswith("ppt/notesSlides/notesSlide") for n in names)
                assert any(n.startswith("ppt/theme/theme") for n in names)
                assert any(n.startswith("ppt/media/") for n in names)
            results[filename] = {
                "package_parts": len(names),
                "internal_relationships": "resolved",
                "baseline_features": "present",
            }
    print(json.dumps(results, indent=2))


def scan(ppm, output):
    # pdftoppm P6 output: read tokens without consuming whitespace-valued pixels.
    with ppm.open("rb") as source:
        tokens = []
        while len(tokens) < 4:
            line = source.readline()
            if not line:
                raise ValueError("Incomplete PPM header")
            if not line.startswith(b"#"):
                tokens.extend(line.split())
        assert tokens[0] == b"P6" and tokens[3] == b"255", tokens
        width, height = map(int, tokens[1:3])
        pixels = source.read()
    assert len(pixels) == width * height * 3
    image = pdf_stream(
        zlib.compress(pixels),
        f"/Type /XObject /Subtype /Image /Width {width} /Height {height} /ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /FlateDecode ".encode(),
    )
    pdf(
        output,
        [
            b"<< /Type /Catalog /Pages 2 0 R >>",
            b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
            b"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Resources << /XObject << /Im0 4 0 R >> >> /Contents 5 0 R >>",
            image,
            pdf_stream(b"q 612 0 0 792 0 0 cm /Im0 Do Q"),
        ],
    )
    print(
        json.dumps(
            {
                "scanned_pdf": str(output),
                "text_layer": "none",
                "raster": [width, height],
            }
        )
    )


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    for command in ("sources", "inspect"):
        commands.add_parser(command).add_argument("directory", type=Path)
    scanner = commands.add_parser("scan")
    scanner.add_argument("ppm", type=Path)
    scanner.add_argument("output", type=Path)
    args = parser.parse_args()
    if args.command == "sources":
        sources(args.directory)
    elif args.command == "inspect":
        inspect(args.directory)
    else:
        scan(args.ppm, args.output)


if __name__ == "__main__":
    main()
