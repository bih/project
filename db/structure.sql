CREATE TABLE "schema_migrations" ("version" varchar NOT NULL);
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "email" varchar DEFAULT '' NOT NULL, "encrypted_password" varchar DEFAULT '' NOT NULL, "reset_password_token" varchar, "reset_password_sent_at" datetime, "remember_created_at" datetime, "sign_in_count" integer DEFAULT 0 NOT NULL, "current_sign_in_at" datetime, "last_sign_in_at" datetime, "current_sign_in_ip" varchar, "last_sign_in_ip" varchar, "account_type" varchar, "first_name" varchar, "last_name" varchar, "mmu_id" varchar, "created_at" datetime, "updated_at" datetime, "course_name" varchar);
CREATE UNIQUE INDEX "index_users_on_email" ON "users" ("email");
CREATE UNIQUE INDEX "index_users_on_reset_password_token" ON "users" ("reset_password_token");
CREATE TABLE "units" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "unit_name" varchar, "unit_year" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "unit_code" varchar);
CREATE TABLE "unit_lecturers" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "unit_id" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "lectures" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "unit_id" integer, "lecture_name" varchar, "user_id" integer, "start_time" datetime, "end_time" datetime, "attendance_expected" integer, "attendance_actual" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "lecture_room" varchar, "lecture_type" varchar);
CREATE TABLE "lecture_students" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "lecture_id" integer, "user_id" integer, "attendance" boolean, "attendance_time" datetime, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "attendance_seconds" integer);
CREATE TABLE "audits" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "auditable_id" integer, "auditable_type" varchar, "associated_id" integer, "associated_type" varchar, "user_id" integer, "user_type" varchar, "username" varchar, "action" varchar, "audited_changes" text, "version" integer DEFAULT 0, "comment" varchar, "remote_address" varchar, "request_uuid" varchar, "created_at" datetime);
CREATE INDEX "auditable_index" ON "audits" ("auditable_id", "auditable_type");
CREATE INDEX "associated_index" ON "audits" ("associated_id", "associated_type");
CREATE INDEX "user_index" ON "audits" ("user_id", "user_type");
CREATE INDEX "index_audits_on_request_uuid" ON "audits" ("request_uuid");
CREATE INDEX "index_audits_on_created_at" ON "audits" ("created_at");
INSERT INTO schema_migrations (version) VALUES ('20150215200616');

INSERT INTO schema_migrations (version) VALUES ('20150215200907');

INSERT INTO schema_migrations (version) VALUES ('20150215200911');

INSERT INTO schema_migrations (version) VALUES ('20150215201224');

INSERT INTO schema_migrations (version) VALUES ('20150215201230');

INSERT INTO schema_migrations (version) VALUES ('20150215201240');

INSERT INTO schema_migrations (version) VALUES ('20150215201558');

INSERT INTO schema_migrations (version) VALUES ('20150217145912');

INSERT INTO schema_migrations (version) VALUES ('20150218020521');

INSERT INTO schema_migrations (version) VALUES ('20150218184813');

INSERT INTO schema_migrations (version) VALUES ('20150218190925');

INSERT INTO schema_migrations (version) VALUES ('20150223004930');

INSERT INTO schema_migrations (version) VALUES ('20150223015018');

INSERT INTO schema_migrations (version) VALUES ('20150223015959');

INSERT INTO schema_migrations (version) VALUES ('20150223163742');

