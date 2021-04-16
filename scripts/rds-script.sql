CREATE DATABASE aws_for_devs;

CREATE TABLE aws_services (
    id INTEGER PRIMARY KEY UNIQUE,
    name VARCHAR(200)
);

INSERT INTO aws_services VALUES (1, 'EC2');
INSERT INTO aws_services VALUES (2, 'S3');
INSERT INTO aws_services VALUES (3, 'RDS');

SELECT * FROM aws_services;