import sys

import fitz  # PyMuPDF


def main() -> int:
    if len(sys.argv) < 3:
        print(
            "Usage: python convert_coupon_pdf_to_png.py <input.pdf> <output.png> [dpi]",
            file=sys.stderr,
        )
        return 2

    input_pdf = sys.argv[1]
    output_png = sys.argv[2]
    dpi = int(sys.argv[3]) if len(sys.argv) >= 4 else 300

    zoom = dpi / 72.0

    doc = fitz.open(input_pdf)
    try:
        page = doc.load_page(0)  # first page
        pix = page.get_pixmap(matrix=fitz.Matrix(zoom, zoom), alpha=False)
        pix.save(output_png)
    finally:
        doc.close()

    print(output_png)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

