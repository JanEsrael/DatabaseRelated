BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE horizontal_miniterm_generator FORCE';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TYPE fragment_list FORCE';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

CREATE OR REPLACE TYPE fragment_list AS TABLE OF VARCHAR2(100);
/

CREATE OR REPLACE TYPE horizontal_miniterm_generator AS OBJECT (
    predicates fragment_list,

    CONSTRUCTOR FUNCTION horizontal_miniterm_generator (predicates fragment_list)
        RETURN SELF AS RESULT,

    MEMBER FUNCTION generate_fragments RETURN fragment_list
);
/

CREATE OR REPLACE TYPE BODY horizontal_miniterm_generator AS
    CONSTRUCTOR FUNCTION horizontal_miniterm_generator (predicates fragment_list)
        RETURN SELF AS RESULT
    IS
    BEGIN
        SELF.predicates := predicates;
        RETURN;
    END;

    MEMBER FUNCTION generate_fragments RETURN fragment_list
    IS
        fragments fragment_list := fragment_list();
        predicate VARCHAR2(100);
        parts fragment_list;
        part_start_pos PLS_INTEGER := 1;
        part_end_pos PLS_INTEGER := 1;
    BEGIN
        FOR i IN 1..self.predicates.COUNT LOOP
            predicate := self.predicates(i);
            parts := fragment_list();
            WHILE part_start_pos <= LENGTH(predicate) LOOP
                part_end_pos := INSTR(predicate, ' AND ', part_start_pos);
                IF part_end_pos = 0 THEN
                    parts.EXTEND;
                    parts(parts.LAST) := TRIM(SUBSTR(predicate, part_start_pos));
                    EXIT;
                END IF;
                parts.EXTEND;
                parts(parts.LAST) := TRIM(SUBSTR(predicate, part_start_pos, part_end_pos - part_start_pos));
                part_start_pos := part_end_pos + LENGTH(' AND ');
            END LOOP;
            parts.EXTEND;
            parts(parts.LAST) := TRIM(SUBSTR(predicate, part_start_pos));
            part_start_pos := 1;
            FOR j IN 1..parts.COUNT LOOP
                fragments.EXTEND;
                fragments(fragments.LAST) := parts(j);
            END LOOP;
        END LOOP;
        RETURN fragments;
    END;
END;
/

DECLARE
    -- Define a list of predicates
    predicates fragment_list := fragment_list(
        'A = 1 AND B = 2',
        'C = 3 AND D = 4'
    );

    -- Instantiate the horizontal_miniterm_generator object
    generator horizontal_miniterm_generator := horizontal_miniterm_generator(predicates);

    -- Declare a variable to hold the generated fragments
    fragments fragment_list;
BEGIN
    -- Generate the fragments
    fragments := generator.generate_fragments;

    -- Output the generated fragments
    FOR i IN 1..fragments.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Fragment ' || i || ': ' || fragments(i));
    END LOOP;
END;
/
