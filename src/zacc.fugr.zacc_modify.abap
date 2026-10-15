FUNCTION zacc_modify.
*"----------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(TABNAME) LIKE  RSRD1-TBMA_VAL OPTIONAL
*"     VALUE(UPDKZ) TYPE  UPDKZ_D OPTIONAL
*"     VALUE(MATNR) LIKE  ZACCDTM-MATNR OPTIONAL
*"     VALUE(CHARG) LIKE  ZACCDTM-CHARG OPTIONAL
*"     VALUE(SENUM) LIKE  ZACCDTM-SENUM OPTIONAL
*"  TABLES
*"      IT_ZACCDTM STRUCTURE  ZACCDTM OPTIONAL
*"      IT_ZACCDTD STRUCTURE  ZACCDTD OPTIONAL
*"      IT_ZACCDTA STRUCTURE  ZACCDTA OPTIONAL
*"      IT_S501 STRUCTURE  S501 OPTIONAL
*"      IT_ZACCMMDT001 STRUCTURE  ZACCMMDT001 OPTIONAL
*"      IT_ZACCMMDT001ER STRUCTURE  ZACCMMDT001ER OPTIONAL
*"      IT_BRANCH STRUCTURE  ZMDCC_BRANCH OPTIONAL
*"----------------------------------------------------------------------
  DATA : lt_zaccdtm   TYPE STANDARD TABLE OF zaccdtm,
         ls_zaccdtm   LIKE LINE OF lt_zaccdtm,
         ls_xaccdtm   TYPE zaccdtm.

  DATA : a VALUE 1.

  CASE tabname.
    WHEN 'ZACCMMDT001'.
      IF it_zaccmmdt001[] IS NOT INITIAL.
        CASE updkz.
          WHEN 'D'.
            DELETE ADJACENT DUPLICATES FROM it_zaccmmdt001 COMPARING ALL FIELDS.
            DELETE zaccmmdt001 FROM TABLE it_zaccmmdt001.
          WHEN OTHERS.
            MODIFY zaccmmdt001 FROM TABLE it_zaccmmdt001.
        ENDCASE.
      ENDIF.
    WHEN 'ZACCMMDT001ER'.
      IF it_zaccmmdt001er[] IS NOT INITIAL.
        CASE updkz.
          WHEN 'D'.
            DELETE ADJACENT DUPLICATES FROM it_zaccmmdt001er COMPARING ALL FIELDS.
            DELETE zaccmmdt001er FROM TABLE it_zaccmmdt001er.
          WHEN OTHERS.
            MODIFY zaccmmdt001er FROM TABLE it_zaccmmdt001er.
        ENDCASE.
      ENDIF.
    WHEN 'ZACCDTM'.
      IF it_zaccdtm[] IS NOT INITIAL.
        CASE updkz.
          WHEN 'D'.
            DELETE ADJACENT DUPLICATES FROM it_zaccdtm COMPARING ALL FIELDS.
            DELETE zaccdtm FROM TABLE it_zaccdtm.
          WHEN OTHERS.
            SELECT *
              FROM zaccdtm
              INTO CORRESPONDING FIELDS OF TABLE lt_zaccdtm
              FOR ALL ENTRIES IN it_zaccdtm
              WHERE matnr = it_zaccdtm-matnr
                AND charg = it_zaccdtm-charg
                AND senum = it_zaccdtm-senum.

            LOOP AT it_zaccdtm INTO ls_xaccdtm.
              CLEAR ls_zaccdtm.
              READ TABLE lt_zaccdtm INTO ls_zaccdtm
                                    WITH KEY matnr = ls_xaccdtm-matnr
                                             charg = ls_xaccdtm-charg
                                             senum = ls_xaccdtm-senum.
              IF ls_xaccdtm-werks IS INITIAL.
                ls_xaccdtm-werks  = ls_zaccdtm-werks.
              ENDIF.
              IF ls_xaccdtm-lgort IS INITIAL.
                ls_xaccdtm-lgort  = ls_zaccdtm-lgort.
              ENDIF.
              IF ls_xaccdtm-erdat IS INITIAL.
                ls_xaccdtm-erdat  = ls_zaccdtm-erdat.
              ENDIF.
              IF ls_xaccdtm-ernam IS INITIAL.
                ls_xaccdtm-ernam  = ls_zaccdtm-ernam.
              ENDIF.
              ls_xaccdtm-vbeln  = ls_zaccdtm-vbeln.
              ls_xaccdtm-aufnr  = ls_zaccdtm-aufnr.
              ls_xaccdtm-z2dbar = ls_zaccdtm-z2dbar.
              MODIFY it_zaccdtm FROM ls_xaccdtm TRANSPORTING werks lgort erdat ernam
                                                             vbeln aufnr z2dbar.
            ENDLOOP.
            MODIFY zaccdtm FROM TABLE it_zaccdtm.
        ENDCASE.
      ENDIF.
    WHEN 'ZACCDTD'.
      IF it_zaccdtd[] IS NOT INITIAL.
        CASE updkz.
          WHEN 'D'.
            DELETE ADJACENT DUPLICATES FROM it_zaccdtd COMPARING ALL FIELDS.
            DELETE zaccdtd FROM TABLE it_zaccdtd.
          WHEN OTHERS.
            MODIFY zaccdtd FROM TABLE it_zaccdtd.
        ENDCASE.
      ENDIF.
    WHEN 'ZACCDTA'.
      IF it_zaccdta[] IS NOT INITIAL.
        CASE updkz.
          WHEN 'D'.
            DELETE ADJACENT DUPLICATES FROM it_zaccdta COMPARING ALL FIELDS.
            DELETE zaccdta FROM TABLE it_zaccdta.
          WHEN OTHERS.
            MODIFY zaccdta FROM TABLE it_zaccdta.
        ENDCASE.
      ENDIF.
    WHEN 'S501'.
      IF it_s501[] IS NOT INITIAL.
        CASE updkz.
          WHEN 'D'.
            DELETE ADJACENT DUPLICATES FROM it_s501 COMPARING ALL FIELDS.
            DELETE s501 FROM TABLE it_s501.
          WHEN OTHERS.
            MODIFY s501 FROM TABLE it_s501.
        ENDCASE.
      ENDIF.
    WHEN 'ZMDCC_BRANCH'.
      IF it_branch[] IS NOT INITIAL.
        CASE updkz.
          WHEN 'D'.
            DELETE ADJACENT DUPLICATES FROM it_branch COMPARING ALL FIELDS.
            DELETE zmdcc_branch FROM TABLE it_branch.
          WHEN OTHERS.
            MODIFY zmdcc_branch FROM TABLE it_branch.
        ENDCASE.
      ENDIF.
  ENDCASE.
ENDFUNCTION.
