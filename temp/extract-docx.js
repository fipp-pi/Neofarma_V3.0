const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const docx = path.join(__dirname, '..', 'ADSPIDWModeloERS.docx');
const outDir = path.join(__dirname, 'docx_unzip');
const xmlPath = path.join(outDir, 'word', 'document.xml');

if (!fs.existsSync(xmlPath)) {
  fs.mkdirSync(outDir, { recursive: true });
  const zipCopy = path.join(__dirname, 'ers.zip');
  fs.copyFileSync(docx, zipCopy);
  execSync(
    `powershell -NoProfile -Command "Expand-Archive -Path '${zipCopy.replace(/'/g, "''")}' -DestinationPath '${outDir.replace(/'/g, "''")}' -Force"`,
    { stdio: 'pipe' }
  );
}

const xml = fs.readFileSync(xmlPath, 'utf8');

// Extrai runs de texto <w:t> e quebra de parágrafo </w:p>
const parts = [];
const re = /<w:p[\s>][\s\S]*?<\/w:p>/g;
let m;
while ((m = re.exec(xml)) !== null) {
  const p = m[0];
  const runs = [];
  const tre = /<w:t[^>]*>([^<]*)<\/w:t>/g;
  let t;
  while ((t = tre.exec(p)) !== null) {
    runs.push(t[1]);
  }
  const line = runs.join('').trim();
  if (line) parts.push(line);
}

const text = parts.join('\n');
const outFile = path.join(__dirname, 'ers-extracted.txt');
fs.writeFileSync(outFile, text, 'utf8');
console.log('lines:', parts.length, 'chars:', text.length);
console.log(text);
