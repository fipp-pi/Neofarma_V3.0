const multer = require('multer');

const allowedMimeTypes = new Set(['image/jpeg', 'image/png', 'image/webp', 'image/gif']);

const uploadProductImage = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 8 * 1024 * 1024 }, // 8MB (antes da compressao)
  fileFilter: (req, file, cb) => {
    if (!allowedMimeTypes.has(file.mimetype)) {
      return cb(new Error('Tipo de arquivo não permitido. Envie JPG, PNG, WEBP ou GIF.'));
    }
    cb(null, true);
  },
});

module.exports = { uploadProductImage };
