REPORT ztdnsd_i010  NO STANDARD PAGE HEADING
                        LINE-SIZE  184
                        LINE-COUNT 65(4).

INCLUDE ztdnsd_i016top.
"data: r_rad5(1), r_rad6(1), r_rad7(1).

SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-091.
PARAMETERS p_vstel LIKE s642-vstel OBLIGATORY.
SELECT-OPTIONS s_sptag FOR s642-sptag MODIF ID re1. " NO INTERVALS. " NO-EXTENSION .
SELECTION-SCREEN SKIP 1.
SELECT-OPTIONS s_vbeln FOR s642-vbeln MODIF ID re1. " NO INTERVALS. " NO-EXTENSION .
SELECT-OPTIONS s_aunr3 FOR s642-aunr3 MODIF ID re1. " NO INTERVALS. " NO-EXTENSION .
SELECT-OPTIONS s_point FOR s642-po_int MODIF ID re1. " NO INTERVALS. " NO-EXTENSION .
SELECT-OPTIONS s_doint FOR s642-doint  MODIF ID re1.
SELECT-OPTIONS s_aunr2 FOR s642-aunr2 MODIF ID re1.
SELECT-OPTIONS s_docust FOR s642-docust MODIF ID re1. " NO INTERVALS. " NO-EXTENSION .
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE TEXT-092.

PARAMETERS  r_rad1 RADIOBUTTON GROUP rea DEFAULT 'X'.

"SELECTION-SCREEN SKIP 1.
PARAMETERS r_rad2 RADIOBUTTON GROUP rea.
PARAMETERS r_rad6 RADIOBUTTON GROUP rea.
PARAMETERS r_rad3 RADIOBUTTON GROUP rea..

PARAMETERS r_rad7 RADIOBUTTON GROUP rea.

PARAMETERS r_rad5 RADIOBUTTON GROUP rea. " DEFAULT 'X'.


SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN : COMMENT 2(3) TEXT-090.
PARAMETERS : r_rad4 AS CHECKBOX DEFAULT 'X' MODIF ID re1.
SELECTION-SCREEN : COMMENT 9(25) TEXT-004.
SELECTION-SCREEN : COMMENT 43(3) TEXT-090.
PARAMETERS : r_rad8 AS CHECKBOX DEFAULT 'X' MODIF ID re1.
SELECTION-SCREEN : COMMENT 49(25) TEXT-005.
SELECTION-SCREEN END OF LINE.
PARAMETERS r_rad9 RADIOBUTTON GROUP rea.


SELECTION-SCREEN END OF BLOCK block2.

AT SELECTION-SCREEN.

INITIALIZATION.
  IF s_sptag IS INITIAL.
    s_sptag-sign = 'I'.
    s_sptag-option = 'BT'.
    s_sptag-high = sy-datum. " - 7. " - 3.
    s_sptag-low = s_sptag-high - 60. "sy-datum - 7.
    s_sptag-low+6(2) = '01'.

    APPEND s_sptag.
  ENDIF.

START-OF-SELECTION.
  IF s_sptag IS INITIAL.
    s_sptag-sign = 'I'.
    s_sptag-option = 'BT'.
    s_sptag-high = sy-datum." - 7. " - 3.
    s_sptag-low = s_sptag-high - 60. "sy-datum - 7.
    s_sptag-low+6(2) = '01'.
    APPEND s_sptag.
  ENDIF.

  PERFORM f_init_data.

  PERFORM f_get_data.
  IF r_rad2 = 'X'.
    DELETE gt_s642_po WHERE po_int IS NOT INITIAL.
    gt_spoint[] =  gt_s642_po[].
    SORT gt_spoint BY po_int.
    DELETE gt_spoint WHERE po_int IS NOT INITIAL.
    IF gt_spoint[] IS NOT INITIAL.
      WRITE: / 'Create PO Intercompany'.
      PERFORM f_proses_pointer_all.
      COMMIT WORK AND WAIT.
    ENDIF.
  ELSEIF r_rad6 = 'X'.
    DELETE gt_s642_all WHERE po_int IS INITIAL .
    gt_spoint[] =  gt_s642_all[].
    SORT gt_spoint BY aunr3.
    DELETE gt_spoint[] WHERE aunr3 IS INITIAL.
    SORT gt_spoint BY po_int.
    DELETE gt_spoint WHERE po_int IS INITIAL .
    PERFORM f_proses_release_point.
  ELSEIF r_rad7 = 'X'.
    DELETE gt_s642_all WHERE doint IS  INITIAL.
    gt_sdoint[] =  gt_s642_all[].
    SORT gt_sdoint BY aunr3.
    DELETE gt_sdoint[] WHERE aunr3 IS INITIAL.
    SORT gt_sdoint BY po_int.
    DELETE gt_sdoint WHERE po_int IS INITIAL.
    SORT gt_sdoint BY doint.
    DELETE gt_sdoint WHERE doint IS  INITIAL.
    IF gt_sdoint[] IS NOT INITIAL.
      WRITE: / 'GI DN Intercompany'.
      PERFORM f_good_issue.
      COMMIT WORK AND WAIT.
    ENDIF.
  ELSEIF r_rad9 = 'X'.
    gt_sdocust[] = gt_s642_all[].
    SORT gt_sdocust BY docust.
    DELETE gt_sdocust[] WHERE docust IS INITIAL.
    SORT gt_sdocust BY aunr2.
    DELETE gt_sdocust[] WHERE aunr2 IS INITIAL.
    SORT gt_sdocust BY doint.
    DELETE gt_sdocust[] WHERE doint IS INITIAL.
    SORT gt_sdocust BY po_int.
    DELETE gt_sdocust[] WHERE po_int IS INITIAL.
    SORT gt_sdocust BY aunr3.
    DELETE gt_sdocust[] WHERE aunr3 IS INITIAL.
    IF gt_sdocust[] IS NOT INITIAL.
      WRITE: / 'GI DN Customer (TDN)'.
      PERFORM f_good_issue_docust.
      COMMIT WORK AND WAIT.
      "      CALL FUNCTION 'ZFMWAIT'.
    ENDIF.
  ELSEIF r_rad1 = 'X'.
    gt_saunr3[] = gt_s642_all[].
    SORT gt_saunr3 BY aunr3.
    DELETE gt_saunr3[] WHERE aunr3 IS NOT INITIAL.
    DELETE gt_saunr3[] WHERE paymt NE 'X'.
    IF gt_saunr3[] IS NOT INITIAL.
      WRITE: / 'Create Material Document'.
      PERFORM f_proses_matdoc.
    ENDIF.
  ELSEIF r_rad3 = 'X'.
    gt_sdoint[] =  gt_s642_all[].
    SORT gt_sdoint BY doint.
    DELETE gt_sdoint WHERE doint IS NOT INITIAL.
    SORT gt_sdoint BY aunr3.
    DELETE gt_sdoint[] WHERE aunr3 IS INITIAL.
    SORT gt_sdoint BY po_int.
    DELETE gt_sdoint WHERE po_int IS INITIAL.
    IF gt_sdoint[] IS NOT INITIAL.
      WRITE: / 'Create DN Intercompany'.
      PERFORM f_proses_dointer.
      COMMIT WORK AND WAIT.
    ENDIF.
  ELSE.
    IF r_rad4 = 'X'.
      gt_ssocust[] = gt_s642_all[].
      SORT gt_ssocust BY aunr2.
      DELETE gt_ssocust[] WHERE aunr2 IS NOT INITIAL.
      SORT gt_ssocust BY doint.
      DELETE gt_ssocust[] WHERE doint IS INITIAL.
      SORT gt_ssocust BY po_int.
      DELETE gt_ssocust[] WHERE po_int IS INITIAL.
      SORT gt_ssocust BY aunr3.
      DELETE gt_ssocust[] WHERE aunr3 IS INITIAL.
      IF gt_ssocust[] IS NOT INITIAL.
        WRITE: / 'Create SO Customer (TDN)'.
        PERFORM f_proses_socust.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.
    IF r_rad8 = 'X'.
      gt_sdocust[] = gt_s642_all[].
      SORT gt_sdocust BY docust.
      DELETE gt_sdocust[] WHERE docust IS NOT INITIAL.
      SORT gt_sdocust BY aunr2.
      DELETE gt_sdocust[] WHERE aunr2 IS INITIAL.
      SORT gt_sdocust BY doint.
      DELETE gt_sdocust[] WHERE doint IS INITIAL.
      SORT gt_sdocust BY po_int.
      DELETE gt_sdocust[] WHERE po_int IS INITIAL.
      SORT gt_sdocust BY aunr3.
      DELETE gt_sdocust[] WHERE aunr3 IS INITIAL.
      IF gt_sdocust[] IS NOT INITIAL.
        WRITE: / 'Create DN Customer (TDN)'.
        PERFORM f_proses_docust.
        COMMIT WORK AND WAIT.
      ENDIF.
    ENDIF.
  ENDIF.
  INCLUDE ztdnsd_i016f01.
