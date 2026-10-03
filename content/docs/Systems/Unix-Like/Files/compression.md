---
date: 2023-08-02T21:00:00+08:00
title: 🗜 Compression
nav_weight: 10 # Upper weight gets higher precedence, optional.
categories:
  - Memo
tags:
  - Linux
---

## Zip / Unzip

```bash
zip <archive.zip> <file1> <file2>     # compress files.
zip -r <archive.zip> <directory>      # compress a directory.
unzip archive_name.zip [-d directory] # decompress an archive.
```

## Gzip / Gunzip

`gzip` is based on the Deflate algorithm (a combination of the LZ77 and Huffman algorithms).

```bash
gzip -l                                          # show the size of the uncompressed file.
gzip <file>                                      # compress.
gunzip <file.gz> | gzip -d <file.gz>             # decompress.
gzip -9 <my_file>                                # compress a file optimally.
gzip -c <file1> <file2> > compressed_file.gz     # compress several files into a single one.
```

## Bzip2 / Bunzip2

`bzip2` is an alternative to `gzip`, more efficient but slower.

```bash
bzip2 <file>                        # compress a file.
bunzip2 <compressed_file.bz2>       # decompress a bzipped file.
```

## XZ / LZMA

LZMA is more efficient and faster than `bzip2`, but uses more memory.

```bash
xz <file>                       # compress a file.
xz -d <compressed_file.xz>      # decompress a file.
```

## Compress / Uncompress (LZW)

`compress` is a compression utility based on the Lempel-Ziv-Welch (LZW) algorithm. It is not the most efficient and, since the compression algorithm is patented in some countries, most GNU/Linux distributions do not include it by default.

```bash
compress <file>                     # compress a file.
uncompress <compressed_file.Z>      # decompress a file.
```