FUNCTION zwmsfm002.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PI_SUBRC) TYPE  SY-SUBRC
*"     VALUE(PI_FUNCTION) TYPE  RS38L-NAME
*"  EXPORTING
*"     REFERENCE(PE_MESSAGE) TYPE  BAPI_MSG
*"----------------------------------------------------------------------

  CASE pi_function.
    WHEN 'L_TO_CREATE_TR'.
      CASE pi_subrc.
        WHEN 1.
          pe_message = 'Foreign lock'.
        WHEN 2.
          pe_message = 'QM Relevant'.
        WHEN 3.
          pe_message = 'TR Completed'.
        WHEN 4.
          pe_message = 'XFELD wrong'.
        WHEN 5.
          pe_message = 'LDEST wrong'.
        WHEN 6.
          pe_message = 'DRUKZ wrong'.
        WHEN 7.
          pe_message = 'TR wrong'.
        WHEN 8.
          pe_message = 'SQUIT forbidden'.
        WHEN 9.
          pe_message = 'No TO created'.
        WHEN 10.
          pe_message = 'Update without commit'.
        WHEN 11.
          pe_message = 'No authority'.
        WHEN 12.
          pe_message = 'Preallocated stock'.
        WHEN 13.
          pe_message = 'Partial transfer req forbidden'.
        WHEN 14.
          pe_message = 'Input error'.
        WHEN 98.
          pe_message = 'Error Call Function'.
          CALL FUNCTION 'FORMAT_MESSAGE'
            EXPORTING
              id        = sy-msgid
              lang      = sy-langu
              no        = sy-msgno
              v1        = sy-msgv1
              v2        = sy-msgv2
              v3        = sy-msgv3
              v4        = sy-msgv4
            IMPORTING
              msg       = pe_message "gv_message
            EXCEPTIONS
              not_found = 1
              OTHERS    = 2.
          IF pe_message IS INITIAL.
            pe_message = 'Error Call Function'.
          ENDIF.
        WHEN 99.
          CALL FUNCTION 'FORMAT_MESSAGE'
            EXPORTING
              id        = sy-msgid
              lang      = sy-langu
              no        = sy-msgno
              v1        = sy-msgv1
              v2        = sy-msgv2
              v3        = sy-msgv3
              v4        = sy-msgv4
            IMPORTING
              msg       = pe_message "gv_message
            EXCEPTIONS
              not_found = 1
              OTHERS    = 2.
          IF pe_message IS INITIAL.
            pe_message = 'Error Call Function'.
          ENDIF.
      ENDCASE.
    WHEN 'L_TO_CONFIRM'.
      CASE pi_subrc.
        WHEN 1.
          pe_message = 'TO Confirmed'.
        WHEN 2.
          pe_message = 'TO does not exist'.
        WHEN 3.
          pe_message = 'Item sudah confirm'.
        WHEN 4.
          pe_message = 'Item Subsystem'.
        WHEN 5.
          pe_message = 'Item does not exist'.
        WHEN 6.
          pe_message = 'Item without zero stock check'.
        WHEN 7.
          pe_message = 'Item with zero stock check'.
        WHEN 8.
          pe_message = 'One item with zero stock check'.
        WHEN 9.
          pe_message = 'Item su bulk storage'.
        WHEN 10.
          pe_message = 'Item no SU bulk storage'.
        WHEN 11.
          pe_message = 'One item SU bulk storage'.
        WHEN 12.
          pe_message = 'Foreign lock'.
        WHEN 13.
          pe_message = 'SQUIT or Quantities'.
        WHEN 14.
          pe_message = 'VQUIT or Quantities'.
        WHEN 15.
          pe_message = 'BQUIT or Quantities'.
        WHEN 16.
          pe_message = 'Quantity wrong'.
        WHEN 17.
          pe_message = 'Double lines'.
        WHEN 18.
          pe_message = 'KZDIF wrong'.
        WHEN 19.
          pe_message = 'No difference'.
        WHEN 20.
          pe_message = 'No negative quantities'.
        WHEN 21.
          pe_message = 'Wrong zero stock check'.
        WHEN 22.
          pe_message = 'SU not found'.
        WHEN 23.
          pe_message = 'No stock on SU'.
        WHEN 24.
          pe_message = 'SU wrong'.
        WHEN 25.
          pe_message = 'Too many su'.
        WHEN 26.
          pe_message = 'Nothing to do'.
        WHEN 27.
          pe_message = 'No unit of measure'.
        WHEN 28.
          pe_message = 'XFELD wrong'.
        WHEN 29.
          pe_message = 'Update without commit'.
        WHEN 30.
          pe_message = 'No authority'.
        WHEN 31.
          pe_message = 'LQNUM missing'.
        WHEN 32.
          pe_message = 'Batch missing'.
        WHEN 33.
          pe_message = 'No sobkz'.
        WHEN 34.
          pe_message = 'No batch'.
        WHEN 35.
          pe_message = 'Source BIN wrong'.
        WHEN 36.
          pe_message = 'Two step confirmation required'.
        WHEN 37.
          pe_message = 'Two step conf not allowed'.
        WHEN 38.
          pe_message = 'Picker belum confirm'.
        WHEN 39.
          pe_message = 'QUKNZ wrong'.
        WHEN 40.
          pe_message = 'HU data wrong'.
        WHEN 41.
          pe_message = 'No HU data required'.
        WHEN 42.
          pe_message = 'HU data missing'.
        WHEN 43.
          pe_message = 'HU not found'.
        WHEN 44.
          pe_message = 'Picking of HU not possible'.
        WHEN 45.
          pe_message = 'Not enough stock in HU'.
        WHEN 46.
          pe_message = 'Serial number data wrong'.
        WHEN 47.
          pe_message = 'Serial numbers not required'.
        WHEN 48.
          pe_message = 'No differences allowed'.
        WHEN 49.
          pe_message = 'Serial number not available'.
        WHEN 50.
          pe_message = 'Serial number data missing'.
        WHEN 51.
          pe_message = 'TO item split not allowed'.
        WHEN 52.
          pe_message = 'Input wrong'.
        WHEN 98.
          pe_message = 'Error Call Function'.
        WHEN 99.
          CALL FUNCTION 'FORMAT_MESSAGE'
            EXPORTING
              id        = sy-msgid
              lang      = sy-langu
              no        = sy-msgno
              v1        = sy-msgv1
              v2        = sy-msgv2
              v3        = sy-msgv3
              v4        = sy-msgv4
            IMPORTING
              msg       = pe_message "gv_message
            EXCEPTIONS
              not_found = 1
              OTHERS    = 2.
          IF pe_message IS INITIAL.
            pe_message = 'Error Call Function'.
          ENDIF.
      ENDCASE.

    WHEN 'L_TO_CREATE_SINGLE'.
      CASE pi_subrc.
        WHEN 1.
          pe_message = 'No TO created'.
        WHEN 2.
          pe_message = 'BWLVS wrong'.
        WHEN 3.
          pe_message = 'BETYP wrong'.
        WHEN 4.
          pe_message = 'BENUM missing'.
        WHEN 5.
          pe_message = 'BETYP missing'.
        WHEN 6.
          pe_message = 'Foreign lock'.
        WHEN 7.
          pe_message = 'Source storage type wrong'.
        WHEN 8.
          pe_message = 'Source storage BIN wrong'.
        WHEN 9.
          pe_message = 'Source storage type missing'.
        WHEN 10.
          pe_message = 'Destination storage type wrong'.
        WHEN 11.
          pe_message = 'Destination storage BIN wrong'.
        WHEN 12.
          pe_message = 'Destination storage type missing'.
        WHEN 13.
          pe_message = 'Return storage type wrong'.
        WHEN 14.
          pe_message = 'Return storage BIN wrong'.
        WHEN 15.
          pe_message = 'Return storage type missing'.
        WHEN 16.
          pe_message = 'SQUIT forbidden'.
        WHEN 17.
          pe_message = 'Manual TO forbidden'.
        WHEN 18.
          pe_message = 'Storage unit type wrong'.
        WHEN 19.
          pe_message = 'Source storage BIN missing'.
        WHEN 20.
          pe_message = 'Destination storage BIN missing'.
        WHEN 21.
          pe_message = 'Special Stock Indicator wrong'.
        WHEN 22.
          pe_message = 'Special Stock Indicator missing'.
        WHEN 23.
          pe_message = 'Special Stock Number missing'.
        WHEN 24.
          pe_message = 'Stock Category wrong'.
        WHEN 25.
          pe_message = 'Storage Section wrong'.
        WHEN 26.
          pe_message = 'XFELD wrong'.
        WHEN 27.
          pe_message = 'Date wrong'.
        WHEN 28.
          pe_message = 'Print code wrong'.
        WHEN 29.
          pe_message = 'Printer destination wrong'.
        WHEN 30.
          pe_message = 'Update without commit'.
        WHEN 31.
          pe_message = 'No authority'.
        WHEN 32.
          pe_message = 'Material not found'.
        WHEN 33.
          pe_message = 'Source Storage Number wrong'.
        WHEN 98.
          pe_message = 'Error Call Function'.
        WHEN 99.
          CALL FUNCTION 'FORMAT_MESSAGE'
            EXPORTING
              id        = sy-msgid
              lang      = sy-langu
              no        = sy-msgno
              v1        = sy-msgv1
              v2        = sy-msgv2
              v3        = sy-msgv3
              v4        = sy-msgv4
            IMPORTING
              msg       = pe_message "gv_message
            EXCEPTIONS
              not_found = 1
              OTHERS    = 2.
          IF pe_message IS INITIAL.
            pe_message = 'Error Call Function'.
          ENDIF.
      ENDCASE.

    WHEN 'L_TO_CREATE_MULTIPLE'.
      CASE pi_subrc.
        WHEN 1.
          pe_message = 'No TO created'.
        WHEN 2.
          pe_message = 'BWLVS wrong'.
        WHEN 3.
          pe_message = 'BETYP wrong'.
        WHEN 4.
          pe_message = 'BENUM missing'.
        WHEN 5.
          pe_message = 'BETYP missing'.
        WHEN 6.
          pe_message = 'Foreign lock'.
        WHEN 7.
          pe_message = 'Source storage type wrong'.
        WHEN 8.
          pe_message = 'Source storage BIN wrong'.
        WHEN 9.
          pe_message = 'Source storage type missing'.
        WHEN 10.
          pe_message = 'Destination storage type wrong'.
        WHEN 11.
          pe_message = 'Destination storage BIN wrong'.
        WHEN 12.
          pe_message = 'Destination storage type missing'.
        WHEN 13.
          pe_message = 'Return storage type wrong'.
        WHEN 14.
          pe_message = 'Return storage BIN wrong'.
        WHEN 15.
          pe_message = 'Return storage type missing'.
        WHEN 16.
          pe_message = 'SQUIT forbidden'.
        WHEN 17.
          pe_message = 'Manual TO forbidden'.
        WHEN 18.
          pe_message = 'Storage Unit Type wrong'.
        WHEN 19.
          pe_message = 'Source storage BIN missing'.
        WHEN 20.
          pe_message = 'Destination storage BIN missing'.
        WHEN 21.
          pe_message = 'Special Stock Indicator wrong'.
        WHEN 22.
          pe_message = 'Special Stock Indicator missing'.
        WHEN 23.
          pe_message = 'Special Stock Number missing'.
        WHEN 24.
          pe_message = 'Stock Category wrong'.
        WHEN 25.
          pe_message = 'Storage Area wrong'.
        WHEN 26.
          pe_message = 'XFELD wrong'.
        WHEN 27.
          pe_message = 'Date wrong'.
        WHEN 28.
          pe_message = 'Print code wrong'.
        WHEN 29.
          pe_message = 'Printer destination wrong'.
        WHEN 30.
          pe_message = 'Update without commit'.
        WHEN 31.
          pe_message = 'No authority'.
        WHEN 32.
          pe_message = 'Material not found'.
        WHEN 33.
          pe_message = 'Storage Unit wrong'.
        WHEN 34.
          pe_message = 'Material missing'.
        WHEN 35.
          pe_message = 'Plant missing'.
        WHEN 36.
          pe_message = 'Quantity missing'.
        WHEN 37.
          pe_message = 'UoM missing'.
        WHEN 38.
          pe_message = 'Storage Location wrong or missing'.
        WHEN 98.
          pe_message = 'Error Call Function'.
        WHEN 99.
          CALL FUNCTION 'FORMAT_MESSAGE'
            EXPORTING
              id        = sy-msgid
              lang      = sy-langu
              no        = sy-msgno
              v1        = sy-msgv1
              v2        = sy-msgv2
              v3        = sy-msgv3
              v4        = sy-msgv4
            IMPORTING
              msg       = pe_message "gv_message
            EXCEPTIONS
              not_found = 1
              OTHERS    = 2.
          IF pe_message IS INITIAL.
            pe_message = 'Error Call Function'.
          ENDIF.
      ENDCASE.
  ENDCASE.
ENDFUNCTION.
