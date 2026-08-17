-- 커뮤니티 서비스 DDL (MySQL 8.x / InnoDB / utf8mb4)

CREATE DATABASE IF NOT EXISTS crud
    DEFAULT CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;
USE crud;

CREATE TABLE users (
    user_id           INT UNSIGNED NOT NULL AUTO_INCREMENT,
    email             VARCHAR(254) NOT NULL COMMENT 'RFC 5321 기준 최대 길이',
    password          VARCHAR(100) NOT NULL COMMENT 'BCrypt 해시(60자). 알고리즘 교체 대비 여유',
    nickname          VARCHAR(10)  NOT NULL,
    profile_image_url VARCHAR(512) NULL COMMENT '파일은 스토리지에, DB에는 경로만',
    created_at        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at        DATETIME     NULL COMMENT 'NULL이면 활성 회원',
    PRIMARY KEY (user_id),
    UNIQUE KEY uk_users_email    (email),
    UNIQUE KEY uk_users_nickname (nickname)
) ENGINE = InnoDB COMMENT = '회원';

CREATE TABLE posts (
    post_id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    title           VARCHAR(26)  NOT NULL COMMENT '기획 제약 26자',
    content         TEXT         NOT NULL,
    attach_file_url VARCHAR(512) NULL,
    view_count      INT UNSIGNED NOT NULL DEFAULT 0,
    user_id         INT UNSIGNED NOT NULL,
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at      DATETIME     NULL,
    PRIMARY KEY (post_id),
    KEY idx_posts_created_at (created_at),
    CONSTRAINT fk_posts_user FOREIGN KEY (user_id)
        REFERENCES users (user_id) ON DELETE CASCADE
) ENGINE = InnoDB COMMENT = '게시글';

CREATE TABLE comments (
    comment_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    content    TEXT         NOT NULL,
    user_id    INT UNSIGNED NOT NULL,
    post_id    INT UNSIGNED NOT NULL,
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME     NULL,
    PRIMARY KEY (comment_id),
    KEY idx_comments_post_id (post_id),
    CONSTRAINT fk_comments_user FOREIGN KEY (user_id)
        REFERENCES users (user_id) ON DELETE CASCADE,
    CONSTRAINT fk_comments_post FOREIGN KEY (post_id)
        REFERENCES posts (post_id) ON DELETE CASCADE
) ENGINE = InnoDB COMMENT = '댓글';

-- 게시글 좋아요. (user_id, post_id) 복합 PK로 중복을 막는다.
-- 좋아요는 토글이라 이력 가치가 없어 soft delete를 두지 않았다.
-- 댓글 좋아요가 생기면 comment_likes를 따로 만든다.
CREATE TABLE likes (
    user_id    INT UNSIGNED NOT NULL,
    post_id    INT UNSIGNED NOT NULL,
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, post_id),
    CONSTRAINT fk_likes_user FOREIGN KEY (user_id)
        REFERENCES users (user_id) ON DELETE CASCADE,
    CONSTRAINT fk_likes_post FOREIGN KEY (post_id)
        REFERENCES posts (post_id) ON DELETE CASCADE
) ENGINE = InnoDB COMMENT = '게시글 좋아요';
