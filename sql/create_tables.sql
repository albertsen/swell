CREATE TABLE workflows (
	id uuid NOT NULL,
	time_created timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	time_updated timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
	definition jsonb NOT NULL,
	document_id varchar(255) NOT NULL,
	"document" jsonb NOT NULL,
    step varchar(255) NULL,
	waiting_for varchar(255) NULL,
	status varchar(255) NULL,
	"result" varchar(255) NULL,
    error jsonb NULL,
	CONSTRAINT workflows_pkey PRIMARY KEY (id)
);
CREATE INDEX workflows_document_id_index ON workflows USING btree (document_id);
CREATE INDEX workflows_id_waiting_for_index ON workflows USING btree (id, waiting_for);
CREATE INDEX workflows_status_index ON workflows USING btree (status);
