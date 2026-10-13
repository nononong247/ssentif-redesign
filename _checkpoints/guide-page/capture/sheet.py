"""검수용 콘택트 시트: python3 sheet.py <dir> <out.png> [glob] [cols]"""
import sys
from PIL import Image, ImageDraw
from pathlib import Path
files=sorted(Path(sys.argv[1]).glob(sys.argv[3] if len(sys.argv)>3 else '*.png'))
cols=int(sys.argv[4]) if len(sys.argv)>4 else 6; cell=(520,540)
rows=max(1,(len(files)+cols-1)//cols)
im=Image.new('RGB',(cols*cell[0],rows*cell[1]),'white'); d=ImageDraw.Draw(im)
for i,f in enumerate(files):
    x=(i%cols)*cell[0]; y=(i//cols)*cell[1]
    p=Image.open(f).convert('RGB'); sz=p.size; p.thumbnail((cell[0]-20,cell[1]-40)); im.paste(p,(x+10,y+30))
    d.text((x+10,y+6),f"{f.name} {sz}",fill='red')
im.save(sys.argv[2]); print(sys.argv[2], im.size)
