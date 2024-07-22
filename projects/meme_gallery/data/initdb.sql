CREATE DATABASE IF NOT EXISTS meme_gallery;

USE meme_gallery;

CREATE TABLE IF NOT EXISTS memes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    url VARCHAR(510) NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    rating INT DEFAULT 0,
    author VARCHAR(100) NOT NULL
);

-- Insertar algunos memes iniciales
INSERT INTO memes (url, title, description, rating, author) VALUES
('https://img.freepik.com/vector-gratis/meme-cuadrado-gato-vibrante-simple_742173-4493.jpg', 'Primer meme', 'Les gané ;)', 5, 'anonymous-rat0182'),
('https://fotografias-compromiso.atresmedia.com/clipping/cmsimages02/2023/04/19/3F653630-CE47-4FC0-ABBD-4AEF83CA4DB7/meme-mucho-texto_58.jpg?crop=316,179,x0,y68&width=1000&height=567&optimize=high&format=webply', 'Mucho texto', '.', 3, 'anonymous-rat0001'),
('https://www.dictionary.com/e/wp-content/uploads/2018/03/This-is-Fine-300x300.jpg', 'Todo va a estar bien', 'Nada que hacerle...', 4, 'trench-pyrate9911');
