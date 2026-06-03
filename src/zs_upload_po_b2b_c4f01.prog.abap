*&---------------------------------------------------------------------*
*&  Include           ZS_UPLOAD_PO_B2B_C4F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_PATH_FORMAT
*&---------------------------------------------------------------------*
FORM f_path_format  USING    fu_separator fu_value.
  CONCATENATE p_path
              fu_separator
              c_interfacein
              fu_separator
         INTO v_interfacein.
  CONCATENATE p_path
              fu_separator
              c_interfaceprocess
              fu_separator
         INTO v_interfaceprocess.
  CONCATENATE p_path
              fu_separator
              c_interfaceerror
         INTO v_interfaceerror.

  CONCATENATE p_path
              fu_separator
              c_interfacesuccess
         INTO v_interfacesuccess.
  CONCATENATE v_interfacesuccess
              fu_separator sy-datum(4)
              fu_separator sy-datum+4(2)
         INTO v_interfacesuccess.

  CONCATENATE p_path
              fu_separator
              c_interfacedelete
         INTO v_interfacedelete.
  CONCATENATE v_interfacedelete
              fu_separator sy-datum(4)
              fu_separator sy-datum+4(2)
         INTO v_interfacedelete.

  CONCATENATE p_path
              fu_separator
              c_logfile
         INTO v_logfile.
  CONCATENATE v_logfile
              fu_separator sy-datum(4)
              fu_separator sy-datum+4(2)
              fu_value
         INTO v_logfile.
ENDFORM.                    " F_PATH_FORMAT

*&---------------------------------------------------------------------*
*&      Form  F_READ_DATA
*&---------------------------------------------------------------------*
FORM f_read_data  USING    fu_dirname fu_filename.
  DATA lv_filename(125) TYPE c.

  CLEAR itabline. REFRESH itabline.
  CONCATENATE fu_dirname fu_filename INTO lv_filename.
  OPEN DATASET lv_filename FOR INPUT IN TEXT MODE
                           ENCODING NON-UNICODE
                           IGNORING CONVERSION ERRORS.
  DO.
    READ DATASET lv_filename INTO wa_itabline.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
    REPLACE '<order:' WITH '<' INTO wa_itabline.
    REPLACE '</order:' WITH '</' INTO wa_itabline.
    APPEND wa_itabline TO itabline.
  ENDDO.
  CLOSE DATASET lv_filename.
ENDFORM.                    " F_READ_DATA

*&---------------------------------------------------------------------*
*&      Form  F_XML_TRANSFORMATION
*&---------------------------------------------------------------------*
FORM f_xml_transformation .
  DATA : ls_multishipmentorder                  TYPE multishipmentorder,
         ls_multishipmentorderlineitem          TYPE multishipmentorderlineitem,
         ls_orderidentification                 TYPE orderidentification.

  DATA : ls_plu                                 TYPE plu,
         ls_description                         TYPE description.

  DATA : ls_po_header      TYPE ts_po_header,
         ls_po_detail      TYPE ts_po_detail,
         ls_po_footer      TYPE ts_po_footer.

  DATA : lv_count          TYPE i.

  CLEAR : multishipmentorder[], orderidentification[], shipto[], multishipmentorderlineitem[].
  CLEAR : gt_po_header[], gt_po_footer[], gt_po_detail[].
  CLEAR : gs_rif_ex, gs_var_text.

  GET REFERENCE OF multishipmentorder INTO gs_xml-value.
  gs_xml-name = 'IMULTISHIPMENTORDER'.
  APPEND gs_xml TO gt_xml.

  GET REFERENCE OF orderidentification INTO gs_xml-value.
  gs_xml-name = 'IORDERIDENTIFICATION'.
  APPEND gs_xml TO gt_xml.

  GET REFERENCE OF shipto INTO gs_xml-value.
  gs_xml-name = 'ISHIPTO'.
  APPEND gs_xml TO gt_xml.

  GET REFERENCE OF multishipmentorderlineitem INTO gs_xml-value.
  gs_xml-name = 'IMULTISHIPMENTORDERLINEITEM'.
  APPEND gs_xml TO gt_xml.

  TRY .
      CALL TRANSFORMATION zs_upload_b2b_c4
      SOURCE XML itabline
      RESULT (gt_xml).
    CATCH cx_xslt_format_error INTO gs_rif_ex.
      gs_var_text = gs_rif_ex->get_text( ).

      IF gs_var_text IS NOT INITIAL.
        PERFORM error_xml USING i_file_list-name.
        l_err       = 'X'.
        l_errheader = 'X'.
      ENDIF.
  ENDTRY.

  IF gs_var_text IS INITIAL.
    LOOP AT multishipmentorder INTO ls_multishipmentorder.
      READ TABLE orderidentification INTO ls_orderidentification INDEX 1.
      IF sy-subrc = 0.
        ls_po_footer-store_id = ls_orderidentification-contentowner-gln.
        ls_po_header-po_no    = ls_orderidentification-contentowner-pono-value.
      ENDIF.

      PERFORM f_modify_date USING ls_multishipmentorder-creationdatetime
                            CHANGING ls_po_header-po_date.

      PERFORM f_modify_date USING ls_multishipmentorder-exp_date
                            CHANGING ls_po_footer-expired.

      APPEND ls_po_header TO gt_po_header.
      APPEND ls_po_footer TO gt_po_footer.
      CLEAR : ls_po_header, ls_po_footer.
    ENDLOOP.

    LOOP AT multishipmentorderlineitem INTO ls_multishipmentorderlineitem.
      PERFORM f_modify_unit USING ls_multishipmentorderlineitem-requestedquantity ''
                            CHANGING ls_po_detail-qty.
      PERFORM f_modify_unit USING ls_multishipmentorderlineitem-netprice_amount ''
                            CHANGING ls_po_detail-price.
*      PERFORM f_modify_unit USING ls_multishipmentorderlineitem-netamount_amount ''
*                            CHANGING ls_po_detail-total.
      ls_po_detail-total = ls_po_detail-qty * ls_po_detail-price.

      ls_po_detail-conversion = '1'.

      ls_po_detail-barcode         = ls_multishipmentorderlineitem-tradeitemidentification-gtin.
      PERFORM f_modify_length USING ls_multishipmentorderlineitem-tradeitemidentification-plu-value
                              CHANGING ls_po_detail-plu.
      ls_po_detail-description     = ls_multishipmentorderlineitem-tradeitemidentification-description-value.

      APPEND ls_po_detail TO gt_po_detail.
      CLEAR ls_po_detail.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_XML_TRANSFORMATION

*&---------------------------------------------------------------------*
*&      Form  ERROR_XML
*&---------------------------------------------------------------------*
FORM error_xml  USING    fu_filename.
  DATA : lv_mstring(255),
         lv_fileindex TYPE i.

  CONCATENATE fu_filename 'error XML :' gs_var_text INTO lv_mstring
  SEPARATED BY space.

  PERFORM f_record_error
           USING  i_file_list-name
                  lv_fileindex
                  'B2B'
                  lv_mstring.

*  i_b2blog-zmessage = lv_mstring.
*  APPEND i_b2blog.
ENDFORM.                    " ERROR_XML

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_DATE
*&---------------------------------------------------------------------*
FORM f_modify_date  USING fu_date
                    CHANGING fc_date.

  DATA : lv_date(100).

  lv_date = fu_date.
  fc_date = lv_date(10).
  TRANSLATE fc_date USING '- '.
  CONDENSE fc_date NO-GAPS.
ENDFORM.                    " F_MODIFY_DATE

*&---------------------------------------------------------------------*
*&      Form  F_PROSES_DATA
*&---------------------------------------------------------------------*
FORM f_proses_data TABLES ft_po_header    LIKE gt_po_header
                          ft_po_detail    LIKE gt_po_detail
                          ft_po_footer    LIKE gt_po_footer.

  DATA : ls_po_header      TYPE ts_po_header,
         ls_po_detail      TYPE ts_po_detail,
         ls_po_footer      TYPE ts_po_footer.

  DATA : l_retcd(1),
         l_ctr TYPE i,
         l_tglpo LIKE sy-datum,
         l_err_valid(1),
         l_b2blive LIKE zplbc-b2blive.

  DATA : ld_datum  LIKE sy-datum,
         ld_netwr  LIKE zsh_b2b-netwr,
         ld_brtwr  LIKE zsh_b2b-brtwr,
         ld_mwsbk  LIKE zsh_b2b-mwsbk,
         ld_tdisa  LIKE zsh_b2b-tdisa.

  CLEAR : i_matb2b, i_zsh_b2b, i_zsd_b2b, v_delete, va_totproses, va_totrecord,
          i_matb2b[], i_zsh_b2b[], i_zsd_b2b[].

  DESCRIBE TABLE itab LINES va_totrecord.

  SELECT *
    FROM zsmat_b2b AS a JOIN zsuom_b2b AS b ON b~zmatnr = a~zmatnr AND
                                               b~kvgr4  = a~kvgr4
    INTO CORRESPONDING FIELDS OF TABLE i_matb2b
    WHERE a~kvgr4 EQ p_kvgr4.

  CLEAR : l_errheader, l_tglpo.

  i_zsh_b2b-mjahr   = sy-datum(4).

  i_b2blog-zlineno  = wa_itab-index.
  i_b2blog-filename = i_file_list-name.

  READ TABLE ft_po_header INTO ls_po_header INDEX 1.
  IF sy-subrc EQ 0.
    i_zsh_b2b-ebeln  = ls_po_header-po_no.
    PERFORM f_date_convert USING ls_po_header-po_date
                           CHANGING ld_datum.
    i_zsh_b2b-bedat  = ld_datum.
    l_tglpo          = ld_datum.
    i_zsh_b2b-waers  = 'IDR'.

    i_b2blog-zpono = ls_po_header-po_no.
    i_b2blog-bedat = ld_datum.
    i_b2blog-fkdat = sy-datum.
    i_b2blog-ernam = sy-uname.
    i_b2blog-kvgr4 = p_kvgr4.

** Check data sudah ada???
    SELECT SINGLE *
      FROM zsh_b2b
      WHERE ebeln = i_zsh_b2b-ebeln AND
            bedat = i_zsh_b2b-bedat.
    IF sy-subrc EQ 0.
      l_err = 'X'. v_delete = 'X'.
      l_errheader = 'X'.
      PERFORM error_data_ada USING ls_po_header-po_no '' '' ''.
    ENDIF.
  ENDIF.

  IF l_err IS INITIAL.
    READ TABLE ft_po_footer INTO ls_po_footer INDEX 1.
    IF sy-subrc EQ 0.
      PERFORM f_date_convert USING ls_po_footer-expired
                           CHANGING ld_datum.
      i_zsh_b2b-bnddt   = ld_datum.
      i_zsh_b2b-patner  = ls_po_footer-store_id.

** Get Customer, Sloff
      CLEAR : wa_adrc, wa_cust.
      SELECT SINGLE addrnumber sort2
        FROM adrc
        INTO CORRESPONDING FIELDS OF wa_adrc
        WHERE sort2 = i_zsh_b2b-patner.
      IF sy-subrc EQ 0.
        SELECT SINGLE adrnr kunnr vkorg vtweg spart vkbur
          FROM kna1vv
          INTO CORRESPONDING FIELDS OF wa_cust
          WHERE adrnr = wa_adrc-addrnumber.
        IF sy-subrc EQ 0.
          i_zsh_b2b-vkorg = wa_cust-vkorg.
          i_zsh_b2b-vkbur = wa_cust-vkbur.
          i_zsh_b2b-kunnr = wa_cust-kunnr.

          DELETE FROM zsb2b_errlog WHERE zpono    EQ i_b2blog-zpono
                                     AND zmessage LIKE 'Cust. code%'
                                     AND filename EQ i_b2blog-filename.
        ENDIF.
      ELSE.
        l_err = 'X'.
        l_errheader = 'X'.
        PERFORM error_data_ada USING '' '' i_zsh_b2b-patner ''.
      ENDIF.

** Check Cabang B2B???
      IF i_zsh_b2b-vkbur IS NOT INITIAL.
        SELECT SINGLE b2blive INTO l_b2blive
          FROM zplbc AS a JOIN tvkol AS b ON b~werks = a~werks AND
                                             b~lgort = a~lgort
          WHERE vstel   = i_zsh_b2b-vkbur
            AND b2blive = 'X'.
        IF sy-subrc NE 0.
          l_err = 'X'.
          l_errheader = 'X'.
          PERFORM error_data_ada USING '' '' '' i_zsh_b2b-vkbur.
        ELSE.
          DELETE FROM zsb2b_errlog WHERE zpono    EQ i_b2blog-zpono
                                     AND zmessage LIKE 'Kode Cabang%'
                                     AND filename EQ i_b2blog-filename.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF l_err IS INITIAL.
    CLEAR: ld_netwr, ld_brtwr.
    LOOP AT ft_po_detail INTO ls_po_detail WHERE barcode NE space.
      ADD 10 TO l_ctr.
      i_zsd_b2b-ebelp  = l_ctr.

      CLEAR: i_matb2b.
      l_err_valid = 'X'.
      LOOP AT i_matb2b WHERE zmatnr = ls_po_detail-plu
                         AND kvgr4  = p_kvgr4.
        IF  l_tglpo >= i_matb2b-valid_fr AND l_tglpo <= i_matb2b-valid_to.
          CLEAR: l_err_valid.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF l_err_valid EQ 'X'.
        PERFORM error_data_ada USING '' ls_po_detail-plu '' ''.
        l_err = 'X'.
      ELSE.
        i_zsd_b2b-matnr    = i_matb2b-matnr.
        i_zsd_b2b-material = ls_po_detail-plu.
        i_zsd_b2b-brtwr    = ls_po_detail-total / 100.
        i_zsd_b2b-waers    = 'IDR'.

        IF ls_po_detail-conversion IS INITIAL.
          i_zsd_b2b-netwr  = 0.
          i_zsd_b2b-kzwi1  = 0.
        ELSE.
          i_zsd_b2b-netwr    = ( ( ( ls_po_detail-price / ls_po_detail-conversion ) *
                                ls_po_detail-qty ) - ls_po_detail-discount ) / 100.
          i_zsd_b2b-kzwi1    = ( ls_po_detail-price / ls_po_detail-conversion ) / 100.
        ENDIF.

        i_zsd_b2b-kzwi2    = ls_po_detail-discount.
        i_zsd_b2b-meins    = i_matb2b-vrkme.
        i_zsd_b2b-conve    = ls_po_detail-conversion.
        i_zsd_b2b-qtypc    = ls_po_detail-qty.
        IF i_matb2b-poqty IS NOT INITIAL.
          i_zsd_b2b-menge  = ( i_zsd_b2b-qtypc * i_matb2b-doqty ) / i_matb2b-poqty.
        ELSE.
          i_zsd_b2b-menge  = 0.
        ENDIF.
        APPEND i_zsd_b2b.

        ADD i_zsd_b2b-netwr TO ld_netwr.
        ADD i_zsd_b2b-brtwr TO ld_brtwr.
        ADD ls_po_detail-ppn TO ld_mwsbk.
        ADD i_zsd_b2b-kzwi2 TO ld_tdisa.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF i_b2blog[] IS NOT INITIAL.
    LOOP AT i_b2blog.
      MOVE-CORRESPONDING i_b2blog TO zsb2b_errlog.
      MODIFY zsb2b_errlog.
    ENDLOOP.
  ENDIF.

  CHECK l_err IS INITIAL.

  i_zsh_b2b-mwsbk     = ld_mwsbk / 100.
  i_zsh_b2b-tdisa     = ld_tdisa / 100.
  i_zsh_b2b-netwr     = ld_netwr.
  i_zsh_b2b-brtwr     = ld_brtwr.
  i_zsh_b2b-fkdat     = sy-datum.
  i_zsh_b2b-aedat     = sy-datum.
  i_zsh_b2b-ernam     = sy-uname.
  i_zsh_b2b-filename  = i_file_list-name(40).

** Get Runing Number
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object      = 'ZSD_B2B'
    IMPORTING
      returncode  = l_retcd
      number      = i_zsh_b2b-znob2b.

  APPEND i_zsh_b2b.
  CLEAR: i_zsd_b2b.
  i_zsd_b2b-znob2b = i_zsh_b2b-znob2b.
  MODIFY i_zsd_b2b TRANSPORTING znob2b WHERE znob2b IS INITIAL.

  MOVE-CORRESPONDING i_zsh_b2b TO i_sukses.
  APPEND i_sukses.

** Material Substitusi per Sales Office
  CALL FUNCTION 'ZSB2B_MATNR'
    TABLES
      pt_zsh_b2b = i_zsh_b2b
      pt_zsd_b2b = i_zsd_b2b.

** Update table B2B
  MODIFY zsh_b2b FROM TABLE i_zsh_b2b.
  MODIFY zsd_b2b FROM TABLE i_zsd_b2b.
ENDFORM.                    " F_PROSES_DATA

*&---------------------------------------------------------------------*
*&      Form  ERROR_DATA_ADA
*&---------------------------------------------------------------------*
FORM error_data_ada  USING    fu_pono fu_plu fu_store fu_vkbur.
  IF fu_pono IS NOT INITIAL.
    CONCATENATE 'PO No. ' fu_pono 'Sudah ada di table'
                    INTO v_mstring SEPARATED BY space.
  ENDIF.

  IF fu_plu IS NOT INITIAL.
    CONCATENATE 'Material' fu_plu 'Belum ada di mapping table'
                    INTO v_mstring SEPARATED BY space.
  ENDIF.

  IF fu_store IS NOT INITIAL.
    CONCATENATE 'Cust. code' fu_store 'Belum ada di master data'
                    INTO v_mstring SEPARATED BY space.
  ENDIF.

  IF fu_vkbur IS NOT INITIAL.
    CONCATENATE 'Kode Cabang ' fu_vkbur 'Belum go live b2b'
                INTO v_mstring SEPARATED BY space.
  ENDIF.

  l_fileindex = itab-index.
  PERFORM f_record_error
           USING  i_file_list-name
                  l_fileindex
                  'B2B'
                  v_mstring.

  i_b2blog-zmessage = v_mstring.
  IF fu_plu IS NOT INITIAL.
    i_b2blog-zlineno  = i_zsd_b2b-ebelp.
  ENDIF.
  APPEND i_b2blog.
ENDFORM.                    " ERROR_DATA_ADA

*&---------------------------------------------------------------------*
*&      Form  F_DATE_CONVERT
*&---------------------------------------------------------------------*
FORM f_date_convert  USING    fu_datum
                     CHANGING fc_datum.

  DATA: str1  TYPE string,
        str2  TYPE string,
        str3  TYPE string,
        mnr(2).

  CLEAR: fc_datum.
  SPLIT fu_datum AT '-' INTO: str1 str2 str3.
  CASE str2.
    WHEN 'Jan'.
      mnr  = '01'.
    WHEN 'Feb'.
      mnr  = '02'.
    WHEN 'Mar'.
      mnr  = '03'.
    WHEN 'Apr'.
      mnr  = '04'.
    WHEN 'May'.
      mnr  = '05'.
    WHEN 'Jun'.
      mnr  = '06'.
    WHEN 'Jul'.
      mnr  = '07'.
    WHEN 'Aug'.
      mnr  = '08'.
    WHEN 'Sep'.
      mnr  = '09'.
    WHEN 'Oct'.
      mnr  = '10'.
    WHEN 'Nov'.
      mnr  = '11'.
    WHEN 'Dec'.
      mnr  = '12'.
  ENDCASE.
  CONCATENATE str3 mnr str1 INTO fc_datum.
ENDFORM.                    " F_DATE_CONVERT

*&---------------------------------------------------------------------*
*&      Form  F_SPLIT_FILE1
*&---------------------------------------------------------------------*
FORM f_split_file1  USING    p_filename TYPE c
                         pdir_src TYPE c
                         pdir_failed TYPE c
                         pdir_ok TYPE c.

  DATA : l_errorfilename(125) TYPE c,
         l_okfilename(125) TYPE c,
         l_filename(125) TYPE c,
         l_filename_dest(125) TYPE c,
         l_filename_src(125) TYPE c,
         l_text(1500) TYPE c,
         l_iserror TYPE c VALUE 'F',
         l_index TYPE i,
         l_extension(5) TYPE c,
         l_error_record TYPE i.

  DATA: l_flname(125) TYPE c,
        l_txt(5)     TYPE c.

  CLEAR wa_itaberror.
  READ TABLE i_itaberror INTO wa_itaberror WITH KEY filename = p_filename.
  IF sy-subrc NE 0.
    p_delete = 'X'.
    SPLIT p_filename AT '.' INTO l_filename l_extension.
    SPLIT l_filename AT '_OK' INTO l_flname l_txt.
    CONCATENATE l_flname '_OK' '.' l_extension INTO l_filename_dest.
    PERFORM f_move_file
           USING
              p_filename
              l_filename_dest
              pdir_src
              pdir_ok.

*{   REPLACE        P01K910797                                        3
*\    IF sy-opsys EQ 'AIX'.
    IF sy-opsys EQ 'AIX' OR sy-opsys EQ 'Linux' OR sy-opsys EQ 'LINUX'.     "original: only for AIX "SOH: Shell Remediation Adjustment 20240403 KRS
*}   REPLACE
      CONCATENATE pdir_ok '/' l_filename_dest INTO l_filename_dest.
    ELSE.
      CONCATENATE pdir_ok '\' l_filename_dest INTO l_filename_dest.
    ENDIF.
    PERFORM f_changefilemode USING l_filename_dest.
  ELSE.
    l_error_record = i_file_list-num_record -
        i_file_list-num_valid_record .
    IF i_file_list-num_record =  l_error_record.
      SPLIT p_filename AT '.' INTO l_filename l_extension.
      SPLIT l_filename AT '_ER' INTO l_flname l_txt.
      CONCATENATE l_flname '_ER' '.' l_extension INTO l_filename_dest.
      PERFORM f_move_file
           USING
              p_filename
              l_filename_dest
              pdir_src
              pdir_failed.
      wa_itaberror-filename = l_filename_dest.
      MODIFY i_itaberror FROM wa_itaberror TRANSPORTING filename WHERE
       filename = p_filename.
*{   REPLACE        P01K910797                                        2
*\      IF sy-opsys EQ 'AIX'.
      IF sy-opsys EQ 'AIX' OR sy-opsys EQ 'Linux' OR sy-opsys EQ 'LINUX'.     "original: only for AIX "SOH: Shell Remediation Adjustment 20240403 KRS
*}   REPLACE
        CONCATENATE pdir_failed '/' l_filename_dest INTO l_filename_dest.
      ELSE.
        CONCATENATE pdir_failed '\' l_filename_dest INTO l_filename_dest.
      ENDIF.
      PERFORM f_changefilemode USING l_filename_dest.
    ELSE.
      SPLIT p_filename AT '.' INTO l_filename l_extension.
*{   REPLACE        P01K910797                                        1
*\      IF sy-opsys EQ 'AIX'.
      IF sy-opsys EQ 'AIX' OR sy-opsys EQ 'Linux' OR sy-opsys EQ 'LINUX'.     "original: only for AIX "SOH: Shell Remediation Adjustment 20240403 KRS
*}   REPLACE
        CONCATENATE pdir_failed '/' l_filename '_ER' '.'
              l_extension INTO l_errorfilename.
        CONCATENATE pdir_ok '/' l_filename '_OK' '.'
              l_extension INTO l_okfilename.
        CONCATENATE pdir_src '/'
             wa_itaberror-filename INTO l_filename_src.
      ELSE.
        CONCATENATE pdir_failed '\' l_filename '_ER' '.'
              l_extension INTO l_errorfilename.
        CONCATENATE pdir_ok '\' l_filename '_OK' '.'
              l_extension INTO l_okfilename.
        CONCATENATE pdir_src '\'
             wa_itaberror-filename INTO l_filename_src.
      ENDIF.
      OPEN DATASET l_filename_src FOR INPUT IN TEXT MODE ENCODING DEFAULT.
      OPEN DATASET l_errorfilename FOR APPENDING IN TEXT MODE ENCODING DEFAULT.
      OPEN DATASET l_okfilename FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.

      l_index = 1.

      DO.
        READ DATASET l_filename_src INTO l_text.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.

        PERFORM f_check_index
                   USING
                      l_index
                   CHANGING
                      l_iserror.

        IF l_text NE ''.
          IF l_iserror = 'T'.
            TRANSFER l_text TO l_errorfilename.
          ELSE.
            TRANSFER l_text TO l_okfilename.
          ENDIF.
        ENDIF.
        l_index = l_index + 1.
      ENDDO.
      CLOSE DATASET l_okfilename.
      CLOSE DATASET l_errorfilename.
      CLOSE DATASET l_filename_src.
      DELETE DATASET l_filename_src.

*     chmod 777
      PERFORM f_changefilemode USING l_okfilename.
      PERFORM f_changefilemode USING l_errorfilename.

      CONCATENATE l_flname '_ER' '.' l_extension INTO
        wa_itaberror-filename.

      MODIFY i_itaberror FROM wa_itaberror TRANSPORTING filename WHERE
       filename = p_filename.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_SPLIT_FILE1

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_ERRLOG
*&---------------------------------------------------------------------*
FORM f_delete_errlog .
  DATA: lt_zsb2b_errlog LIKE zsb2b_errlog OCCURS 0 WITH HEADER LINE,
        ld_pono  LIKE zsb2b_errlog-zpono,
        ld_bedat LIKE zsb2b_errlog-bedat.

  IF i_sukses[] IS NOT INITIAL OR p_delete = 'X'.
    DELETE FROM zsb2b_errlog WHERE zpono = i_zsh_b2b-ebeln AND
                                   bedat = i_zsh_b2b-bedat.
  ENDIF.
ENDFORM.                    " F_DELETE_ERRLOG

*&---------------------------------------------------------------------*
*&      Form  F_FILE_DELETE
*&---------------------------------------------------------------------*
FORM f_file_delete  USING    p_filename TYPE c
                         pdir_src TYPE c
                         pdir_delete TYPE c.

  DATA : l_filename(125) TYPE c,
         l_filename_dest(125) TYPE c,
         l_filename_src(125) TYPE c,
         l_extension(5) TYPE c.

  SPLIT p_filename AT '.' INTO l_filename l_extension.
  CONCATENATE l_filename '_DLT' '.' l_extension INTO l_filename_dest.
  PERFORM f_move_file USING p_filename
                            l_filename_dest
                            pdir_src
                            pdir_delete.

*{   REPLACE        P01K910797                                        1
*\  IF sy-opsys EQ 'AIX'.
  IF sy-opsys EQ 'AIX' OR sy-opsys EQ 'Linux' OR sy-opsys EQ 'LINUX'.     "original: only for AIX "SOH: Shell Remediation Adjustment 20240403 KRS
*}   REPLACE
    CONCATENATE pdir_delete '/' l_filename_dest INTO l_filename_dest.
  ELSE.
    CONCATENATE pdir_delete '\' l_filename_dest INTO l_filename_dest.
  ENDIF.
  PERFORM f_changefilemode USING l_filename_dest.
ENDFORM.                    " F_FILE_DELETE

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_UNIT
*&---------------------------------------------------------------------*
FORM f_modify_unit  USING    fu_value fu_split
                    CHANGING fc_value.
  DATA : lv_string    TYPE string.

  IF fu_split IS INITIAL.
    fc_value  = fu_value.
  ELSE.
    SPLIT fu_value AT fu_split INTO fc_value lv_string.
    CONDENSE fc_value NO-GAPS.
  ENDIF.
ENDFORM.                    " F_MODIFY_UNIT

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_LENGTH
*&---------------------------------------------------------------------*
FORM f_modify_length  USING    fu_value
                      CHANGING fc_value.
  DATA : lv_length    TYPE i.

  lv_length = STRLEN( fu_value ).
  IF lv_length > 2.
    lv_length = lv_length - 2.
    fc_value = fu_value(lv_length).
  ENDIF.
ENDFORM.                    " F_MODIFY_LENGTH

*&---------------------------------------------------------------------*
*&      Form  F_CEK_FILE
*&---------------------------------------------------------------------*
FORM f_cek_file  USING    fu_name fu_path.

*  PERFORM f_file_delete USING fu_name fu_path v_interfacedelete.

ENDFORM.                    " F_CEK_FILE
