DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,  --means various char limited to 255 char
  lname VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS questions;
CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body VARCHAR(255) NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;
CREATE TABLE question_follows (
  question_id INTEGER NOT NULL,
  follower_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (follower_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS replies;
CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body VARCHAR(255) NOT NULL,
  question_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  reply_author_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_reply_id) REFERENCES replies(id),
  FOREIGN KEY (reply_author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_likes;
CREATE TABLE question_likes (
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);


INSERT INTO
  users (fname, lname)
VALUES
  ('Ursula', 'Goldstein'),
  ('Seung', 'Park'),
  ('John', 'Smith'),
  ('Julie', 'Andrews');

INSERT INTO
  questions (title, body, author_id)
VALUES
  ('Hello Friend', 'Hello! How are you doing?', 1),
  ('Bye Friend', 'When are you coming back?', 2),
  ('Please Help!', 'Can someone explain SQL to me?', 1),
  ('Explore!', 'Where can i find some gold?', 3),
  ('Quick Question!', 'Why does no one like me?', 4);

INSERT INTO
  replies (body, question_id, parent_reply_id, reply_author_id)
VALUES
  ('I am doing well!', 1, NULL, 2),
  ('That is great!', 1, 1, 1),
  ('On Monday!', 2, NULL, 1),
  ('I am coming back on Tuesday', 2, NULL, 3),
  ('Ok cool!', 2, 3, 4),
  ('Because you use INNER JOINS', 5, NULL, 1),
  ('Use OUTER JOINS!', 5, 6, 2),
  ('Still no answer...', 4, NULL, 3);

INSERT INTO
  question_follows(question_id, follower_id)
VALUES
  (1,2),
  (2,1),
  (2,4),
  (5,1),
  (5,2),
  (4,4);

INSERT INTO
  question_likes(question_id, user_id)
VALUES
  (1,2),
  (2,1),
  (2,3),
  (2,4),
  (4,2),
  (4,1);


-- cat import_db.sql | sqlite3 questions.db
