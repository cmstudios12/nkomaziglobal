-- Nkomazi Global FET College: run AFTER the original supabase-setup.sql.
-- Run once in the SQL editor of project zvqssclpdgcwxkssfchk.
-- Generates unique, database-issued student APPLICATION numbers.
-- Existing admin portal keeps using public.applications unchanged.

CREATE SEQUENCE IF NOT EXISTS public.college_student_number_seq START WITH 1;
ALTER TABLE public.applications ADD COLUMN IF NOT EXISTS student_number text;

CREATE OR REPLACE FUNCTION public.assign_college_student_number()
RETURNS trigger LANGUAGE plpgsql SET search_path = '' AS $$
BEGIN
  IF NEW.student_number IS NULL THEN
    NEW.student_number := 'NGF-' || NEW.intake_year::text || '-' ||
      lpad(nextval('public.college_student_number_seq')::text,6,'0');
  END IF;
  RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_assign_college_student_number ON public.applications;
CREATE TRIGGER trg_assign_college_student_number
BEFORE INSERT ON public.applications FOR EACH ROW
EXECUTE FUNCTION public.assign_college_student_number();

-- Give existing applications a unique reference, if any exist.
UPDATE public.applications
SET student_number = 'NGF-' || intake_year::text || '-' ||
  lpad(nextval('public.college_student_number_seq')::text,6,'0')
WHERE student_number IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS applications_student_number_unique
ON public.applications(student_number);

-- Public can submit, but cannot read the applications table.
-- This function returns ONLY the number for the newly created application.
CREATE OR REPLACE FUNCTION public.submit_college_application(
 p_first_name text,p_last_name text,p_email text,p_phone text,
 p_current_grade text,p_package text,p_subjects text,p_message text DEFAULT NULL
) RETURNS text
LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE new_number text;
BEGIN
 IF length(btrim(coalesce(p_first_name,''))) NOT BETWEEN 1 AND 100 OR
    length(btrim(coalesce(p_last_name,''))) NOT BETWEEN 1 AND 100 OR
    length(btrim(coalesce(p_email,''))) NOT BETWEEN 3 AND 255 OR
    position('@' in p_email) < 2 OR
    length(btrim(coalesce(p_phone,''))) NOT BETWEEN 5 AND 25 OR
    length(btrim(coalesce(p_current_grade,''))) NOT BETWEEN 1 AND 80 OR
    length(btrim(coalesce(p_package,''))) NOT BETWEEN 1 AND 100 OR
    length(btrim(coalesce(p_subjects,''))) NOT BETWEEN 1 AND 1000 OR
    length(coalesce(p_message,'')) > 1500
 THEN RAISE EXCEPTION 'Invalid application fields'; END IF;
 INSERT INTO public.applications
 (intake_year,first_name,last_name,email,phone,current_grade,package,subjects,message,status)
 VALUES (2027,btrim(p_first_name),btrim(p_last_name),btrim(p_email),btrim(p_phone),
         btrim(p_current_grade),btrim(p_package),btrim(p_subjects),nullif(btrim(p_message),''),'pending')
 RETURNING student_number INTO new_number;
 RETURN new_number;
END;
$$;
REVOKE ALL ON FUNCTION public.submit_college_application(text,text,text,text,text,text,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.submit_college_application(text,text,text,text,text,text,text,text) TO anon,authenticated;

-- IMPORTANT PRODUCTION NOTE:
-- Add server-side rate limiting / CAPTCHA verification before public launch
-- to prevent automated spam. Do not put service_role keys in browser code.
-- Sending emails is NOT configured; students must save the number shown onscreen.
