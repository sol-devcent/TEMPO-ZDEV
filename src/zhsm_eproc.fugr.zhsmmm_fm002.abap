FUNCTION zhsmmm_fm002.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_SUBMI) TYPE  SUBMI
*"     VALUE(PI_ZALNO) TYPE  ZALNO OPTIONAL
*"     VALUE(PI_FILENAME) TYPE  IBIPPARMS-PATH OPTIONAL
*"     VALUE(PI_NEW) TYPE  XFELD OPTIONAL
*"     VALUE(PI_PRGRP) TYPE  PGMI-PRGRP OPTIONAL
*"     VALUE(PI_DEST) TYPE  SSFCOMPOP-TDDEST DEFAULT 'TSTTNT17_EP01'
*"     VALUE(PI_GETOFF) TYPE  SSFCTRLOP-GETOTF OPTIONAL
*"     VALUE(PI_TDNOPREV) TYPE  SSFCOMPOP-TDNOPREV OPTIONAL
*"     VALUE(PI_PREVIEW) TYPE  SSFCTRLOP-PREVIEW OPTIONAL
*"     VALUE(PI_NODIALOG) TYPE  SSFCTRLOP-NO_DIALOG OPTIONAL
*"  TABLES
*"      PT_006 STRUCTURE  ZHSMMMDT006 OPTIONAL
*"      PT_007 STRUCTURE  ZHSMMMDT007 OPTIONAL
*"      PT_FORM01 STRUCTURE  ITCOO OPTIONAL
*"      PT_FORM02 STRUCTURE  ITCOO OPTIONAL
*"      PT_FORM03 STRUCTURE  ITCOO OPTIONAL
*"      PT_FORM04 STRUCTURE  ITCOO OPTIONAL
*"  EXCEPTIONS
*"      PRODUCT_GROUP_ERROR
*"----------------------------------------------------------------------
  DATA : lt_x004p     TYPE STANDARD TABLE OF zgdmmt004p,
         ls_004z      TYPE zgdmmt004z,
         lv_subrc     TYPE sy-subrc.

  SELECT *
    FROM zgdmmt0004x
    INTO CORRESPONDING FIELDS OF TABLE gt_004
    WHERE type = 'NEW'.

  IF pi_new IS INITIAL.
*{   REPLACE        P01K910262                                        1
*\    SELECT *
*\      FROM zgdmmt004z
*\      INTO CORRESPONDING FIELDS OF TABLE gt_004z
*\      WHERE zalno = pi_zalno
*\        AND submi = pi_submi.
    "Start SOH: Shell SCI Adjustment 20240221 KRS
    SELECT *
      FROM zgdmmt004z
      INTO CORRESPONDING FIELDS OF TABLE gt_004z
      WHERE zalno = pi_zalno
        AND submi = pi_submi
      ORDER BY PRIMARY KEY.
    "End SOH: Shell SCI Adjustment 20240221 KRS
*}   REPLACE

*    SORT gt_004z BY zaldt DESCENDING.
    DELETE ADJACENT DUPLICATES FROM gt_004z COMPARING zalno submi.

    SELECT *
      FROM zgdmmt004x
      INTO CORRESPONDING FIELDS OF TABLE gt_004x
      WHERE zalno = pi_zalno.

* Form Alokasi SP
    SELECT *
      FROM zgdmmt004c
      INTO CORRESPONDING FIELDS OF TABLE gt_004c
      WHERE zalno = pi_zalno.

* Lampiran Actual PO
    SELECT *
      FROM zgdmmt004p
      INTO CORRESPONDING FIELDS OF TABLE gt_004p
      WHERE zalno = pi_zalno.

* Lampiran Alokasi SP
    SELECT *
      FROM zgdmmt004y
      INTO CORRESPONDING FIELDS OF TABLE gt_004y
      WHERE zalno = pi_zalno.

* Vendor
    lt_x004p[] = gt_004p[].
    SORT lt_x004p BY lifnr.
    DELETE ADJACENT DUPLICATES FROM lt_x004p COMPARING lifnr.
    IF lt_x004p[] IS NOT INITIAL.
      SELECT *
        FROM lfa1
        INTO CORRESPONDING FIELDS OF TABLE gt_lfa1
        FOR ALL ENTRIES IN lt_x004p
        WHERE lifnr = lt_x004p-lifnr.
    ENDIF.

    READ TABLE gt_004z INTO ls_004z INDEX 1.

    CALL FUNCTION 'HR_99S_GET_QUARTER'
      EXPORTING
        im_date    = ls_004z-zaldt
      IMPORTING
        ex_quarter = gs_quarter.

    IF gt_004z[] IS NOT INITIAL.
      SELECT *
        FROM zhsmmmdt006
        INTO CORRESPONDING FIELDS OF TABLE gt_006
        FOR ALL ENTRIES IN gt_004z
        WHERE prgrp = gt_004z-prgrp
          AND submi = gt_004z-submi
          AND zalno = gt_004z-zalno.

      SELECT *
        FROM zhsmmmdt007
        INTO CORRESPONDING FIELDS OF TABLE gt_007
        FOR ALL ENTRIES IN gt_004z
        WHERE prgrp = gt_004z-prgrp
          AND submi = gt_004z-submi
          AND zalno = gt_004z-zalno.
    ENDIF.

    PERFORM f_print_data TABLES pt_form01 pt_form02 pt_form03 pt_form04
                         USING pi_prgrp pi_dest pi_nodialog pi_tdnoprev
                               pi_preview pi_getoff.
  ELSE.
    IF pi_filename IS NOT INITIAL.
      PERFORM f_get_data TABLES pt_006 pt_007
                         USING pi_filename pi_prgrp pi_submi pi_zalno
                         CHANGING lv_subrc.
    ENDIF.
  ENDIF.

  CASE lv_subrc.
    WHEN 1.
      RAISE product_group_error.
  ENDCASE.
ENDFUNCTION.
