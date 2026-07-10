REPORT zgd_query_call MESSAGE-ID aq.

INCLUDE rsaqcomc.
INCLUDE rsaqcom1.

PARAMETERS: p_wsid   AS CHECKBOX,
            p_ugroup TYPE bgname,
            p_query  TYPE quname,
            p_vari   TYPE vari.




* call via RSAQ_QUERY_CALL (release >= 46A)
CALL FUNCTION 'RSAQ_QUERY_CALL'
     EXPORTING
          workspace                   = act_workspace
          query                       = p_query
          usergroup                   = p_ugroup
          variant                     = p_vari
          skip_selscreen              = space
     EXCEPTIONS
          no_usergroup                = 1
          no_query                    = 2
          query_locked                = 3
          generation_cancelled        = 4
          no_selection                = 5
          no_variant                  = 6
          just_via_variant            = 7
          no_submit_auth              = 8
          no_data_selected            = 9
          data_to_memory_not_possible = 10
          OTHERS                      = 11.
CASE sy-subrc.
  WHEN 0.
  WHEN 1.
    MESSAGE i812 WITH p_ugroup.
  WHEN 2.
    MESSAGE i236 WITH p_query p_ugroup.
  WHEN 6.
    MESSAGE i223 WITH p_vari.
  WHEN OTHERS.
    MESSAGE i835 WITH p_query p_ugroup.
ENDCASE.
