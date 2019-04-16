CREATE TABLE workflows (
	id uuid NOT NULL,
	time_created timestamp NOT NULL,
	time_updated timestamp NOT NULL,
	definition jsonb NOT NULL,
	document_id varchar(255) NOT NULL,
	"document" jsonb NOT NULL,
    current_step varchar(255) NULL,
	waiting_for varchar(255) NULL,
	status varchar(255) NULL,
	"result" varchar(255) NULL,
    last_error jsonb NULL,
	CONSTRAINT workflows_pkey PRIMARY KEY (id)
);
CREATE INDEX workflows_document_id_index ON public.workflows USING btree (document_id);
CREATE INDEX workflows_id_waiting_for_index ON public.workflows USING btree (id, waiting_for);
CREATE INDEX workflows_status_index ON public.workflows USING btree (status);
