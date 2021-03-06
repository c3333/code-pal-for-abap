CLASS y_check_self_reference DEFINITION PUBLIC INHERITING FROM y_check_base CREATE PUBLIC .
  PUBLIC SECTION.
    METHODS constructor.
  PROTECTED SECTION.
    METHODS inspect_tokens REDEFINITION.
  PRIVATE SECTION.
    METHODS has_self_reference IMPORTING statement TYPE sstmnt
                               RETURNING VALUE(result) TYPE abap_bool.
ENDCLASS.


CLASS Y_CHECK_SELF_REFERENCE IMPLEMENTATION.

  METHOD constructor.
    super->constructor( ).

    description = 'Self-Reference'(001).
    category    = 'Y_CHECK_CATEGORY'.
    position    = '790'.
    version     = '0000'.
    has_documentation = abap_true.

    settings-pseudo_comment = '"#EC SELF_REF' ##NO_TEXT.
    settings-disable_threshold_selection = abap_true.
    settings-threshold = 0.
    settings-documentation = |{ c_docs_path-checks }self-reference.md|.

    y_message_registration=>add_message(
      EXPORTING
        check_name     = me->myname
        text           = '[Clean Code]: Omit the self-reference me when calling an instance method!'(102)
        pseudo_comment = settings-pseudo_comment
      CHANGING
        messages       = me->scimessages ).
  ENDMETHOD.

  METHOD inspect_tokens.

    CHECK statement-type = 'A'
    OR statement-type = 'C'.

    CHECK has_self_reference( statement ).

    DATA(configuration) = detect_check_configuration( statement ).

    IF configuration IS INITIAL.
      RETURN.
    ENDIF.

    raise_error( statement_level = statement-level
                 statement_index = index
                 statement_from  = statement-from
                 error_priority  = configuration-prio ).

  ENDMETHOD.

  METHOD has_self_reference.
    LOOP AT ref_scan_manager->get_tokens( ) ASSIGNING FIELD-SYMBOL(<token>)
    FROM statement-from TO statement-to
    WHERE str CS 'me->'.
      result = abap_true.
      RETURN.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
