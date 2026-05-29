DATA: usergroups LIKE usgroups OCCURS 0 WITH HEADER LINE.

CALL FUNCTION 'SUSR_USER_GROUP_GROUPS_GET'
  EXPORTING
    bname      = sy-uname
  TABLES
    usergroups = usergroups.

IF sy-subrc = 0.
  READ TABLE usergroups WITH KEY usergroup = 'ZHO'.
  IF sy-subrc = 0.
    usergroup = usergroups-usergroup.
  ELSE.
    CLEAR usergroup.
  ENDIF.
ENDIF.

















