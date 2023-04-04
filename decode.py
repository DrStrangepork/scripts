#!/usr/bin/env python3
import re
import sys
import urllib.parse

URL = sys.argv[1].replace('https://signin.aws.amazon.com/signin?redirect_uri=', '')
URL = urllib.parse.unquote(URL)
while (re.search(r'hashArgs=?%', URL) is not None):
    URL = urllib.parse.unquote(URL)
URL = URL.split('&isauthcode')[0]
print(URL)
