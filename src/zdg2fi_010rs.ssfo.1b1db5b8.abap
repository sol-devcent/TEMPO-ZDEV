READ TABLE t_reguh into s_reguh INDEX 1.
*"break 3
*break dg2_co01.
*
*CLEAR t_printed[].
IF D_MULTIPLE EQ 'X'.
  READ TABLE t_printed1 INTO s_printed WITH KEY laufd = s_reguh-laufd
                               laufi = s_reguh-laufi
                               zbukr = s_reguh-zbukr.
*  t_printed[] = t_printed1[].
ELSE.
  READ TABLE t_printed1 INTO s_printed WITH KEY laufd = s_reguh-laufd
                               laufi = s_reguh-laufi
                               zbukr = s_reguh-zbukr
                               lifnr = s_reguh-lifnr.
*  t_printed[] = t_printed1[].
*  DELETE t_printed WHERE lifnr ne s_reguh-lifnr.
*
ENDIF.






