# PDF
PDF tips.

## Size Reduction
You can use ImageMagick to reduce the size of a PDF by lowering its resolution.
From https://apple.stackexchange.com/questions/297417/how-to-decrease-pdf-size-without-losing-quality :

```
brew install imagemagick
convert -density 72 oldfile.pdf new.pdf
```

where 72 is the target DPI.

## PDF Join/Merge
Best option is to use `pdfunite`, from `brew install poppler` which also installs other useful PDF tools:

```
pdfunit one.pdf sub/*.pdf merged.pdf
```

- **References**:
  - <https://apple.stackexchange.com/questions/230437/how-can-i-combine-multiple-pdfs-using-the-command-line>
  - <https://www.mankier.com/package/poppler-utils>
