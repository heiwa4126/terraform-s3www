#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
/etc/mime.types から mime.tf を作る

`./make_mimetf.py > mime.tf && terrraform fmt`
"""

import re

COMMENT = re.compile(r"^\s*#")

h = dict()


def perline(l: str):
    if COMMENT.match(l):
        return
    l = str.strip(l)
    if l == "":
        return
    a = re.split(r"\s+", l)
    if len(a) == 1:
        return
    for ext in a[1:]:
        h[ext] = a[0]


def main():
    # parse
    with open("/etc/mime.types") as f:
        for l in f:
            perline(l)

    # # some specials
    # h["ico"] = "image/vnd.microsoft.icon"

    # output
    print(
        """locals {
  mime_types = {"""
    )

    for ext in sorted(h.keys()):
        print('".{}": "{}",'.format(ext, h[ext]))
    print(
        """}
}"""
    )


if __name__ == "__main__":
    main()
