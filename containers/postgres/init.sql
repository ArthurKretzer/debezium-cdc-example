CREATE SCHEMA school;

SET
    search_path TO school;

CREATE TABLE student (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

INSERT INTO
    student
VALUES
    (2, 'test');

ALTER TABLE
    student REPLICA IDENTITY FULL;