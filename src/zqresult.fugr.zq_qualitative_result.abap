FUNCTION zq_qualitative_result.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(PRUEFLOS) TYPE  QAMV-PRUEFLOS
*"     REFERENCE(VORGLFNR) TYPE  QAMV-VORGLFNR
*"     REFERENCE(MERKNR) TYPE  QAMV-MERKNR
*"     REFERENCE(STICHPRVER) TYPE  QAMV-STICHPRVER
*"     REFERENCE(CASE) TYPE  I
*"  EXPORTING
*"     REFERENCE(RESULT) TYPE  CHAR50
*"  TABLES
*"      T_QDSV STRUCTURE  QDSV
*"      T_QAMR STRUCTURE  QAMR
*"      T_QASE STRUCTURE  QASE
*"      T_QASR STRUCTURE  QASR
*"      T_QAPP STRUCTURE  QAPP
*"----------------------------------------------------------------------
  DATA: ld_len       TYPE i,
        ld_kurztext  LIKE qpct-kurztext,
        ld_confirm(10),
        ld_nonconf(10),
        ld_accept(10),
        ld_reject(10),
        ld_an(10),
        ld_ap(10),
        ld_force(10),
        ld_flag      TYPE i,
        ld_sesuai(20),
        ld_tdksesuai(20).

  CLEAR:  result, ld_confirm, ld_nonconf, ld_accept, ld_reject, ld_an, ld_ap, ld_force, ld_flag.

  READ TABLE t_qamr WITH KEY prueflos = prueflos
                             vorglfnr = vorglfnr
                             merknr   = merknr
  BINARY SEARCH.
  IF sy-subrc EQ 0.
    CASE t_qamr-iststpanz.
      WHEN 0.
        IF t_qamr-gruppe1 IS NOT INITIAL AND
          t_qamr-code1 IS NOT INITIAL.
          ld_len = STRLEN( t_qamr-code1 ).
          ld_len = ld_len - 2.

          READ TABLE t_qdsv WITH KEY stichprver = stichprver.
          IF sy-subrc EQ 0.
            ld_flag = 2.
            CASE t_qamr-code1+ld_len(2).
              WHEN '10'.
                ld_sesuai    = 'SESUAI'.
              WHEN '20'.
                ld_tdksesuai = 'TIDAK SESUAI'.
            ENDCASE.
          ELSE.
            CASE t_qamr-code1+ld_len(2).
              WHEN '10'.
                ADD 1 TO ld_confirm.
              WHEN '20'.
                ADD 1 TO ld_nonconf.
            ENDCASE.

            LOOP AT t_qapp WHERE prueflos = prueflos AND
                                 vorglfnr = vorglfnr.

              IF t_qapp-vcode IS NOT INITIAL.
                ld_len = STRLEN( t_qapp-vcode ).
                ld_len = ld_len - 2.

                CASE t_qapp-vcode+ld_len(2).
                  WHEN '10'.
                    ADD 1 TO ld_accept.
                  WHEN '20'.
                    ADD 1 TO ld_reject.
                  WHEN '30'.
                    ADD 1 TO ld_an.
                  WHEN '40'.
                    ADD 1 TO ld_ap.
                ENDCASE.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ELSE.
          IF t_qase[] IS NOT INITIAL.
            LOOP AT t_qase WHERE prueflos = prueflos AND
                                 vorglfnr = vorglfnr AND
                                 merknr   = merknr.
              IF t_qase-mbewertg IS NOT INITIAL.
                CASE t_qase-mbewertg.
                  WHEN 'A'.
                    ADD 1 TO ld_confirm.
                  WHEN 'R'.
                    ADD 1 TO ld_nonconf.
                ENDCASE.
              ENDIF.

              IF t_qase-code1 IS NOT INITIAL.
                ld_len = STRLEN( t_qase-code1 ).
                ld_len = ld_len - 2.
                CASE t_qase-code1+ld_len(2).
                  WHEN '10'.
                    ADD 1 TO ld_accept.
                  WHEN '20'.
                    ADD 1 TO ld_reject.
                  WHEN '30'.
                    ADD 1 TO ld_an.
                  WHEN '40'.
                    ADD 1 TO ld_ap.
                ENDCASE.
              ENDIF.
            ENDLOOP.
            IF sy-subrc NE 0.
              ld_flag = 1.
              ld_force = t_qamr-anzfehleh.
            ENDIF.
          ELSE.
            ld_flag = 1.
            ld_force = t_qamr-anzfehleh.
          ENDIF.
        ENDIF.

      WHEN 1.
        IF t_qase[] IS NOT INITIAL.
          LOOP AT t_qase WHERE prueflos = prueflos AND
                               vorglfnr = vorglfnr AND
                               merknr   = merknr.
            IF t_qase-mbewertg IS NOT INITIAL.
              CASE t_qase-mbewertg.
                WHEN 'A'.
                  ADD 1 TO ld_confirm.
                WHEN 'R'.
                  ADD 1 TO ld_nonconf.
              ENDCASE.
            ENDIF.
          ENDLOOP.
          IF sy-subrc EQ 0.
            READ TABLE t_qasr WITH KEY prueflos = prueflos
                                       vorglfnr = vorglfnr
                                       merknr   = merknr
            BINARY SEARCH.
            IF sy-subrc EQ 0.
              IF t_qasr-mbewertg IS NOT INITIAL.
                IF t_qasr-code1 IS NOT INITIAL.
                  ld_len = STRLEN( t_qasr-code1 ).
                  ld_len = ld_len - 2.

                  CASE t_qasr-code1+ld_len(2).
                    WHEN '10'.
                      ADD 1 TO ld_accept.
                    WHEN '20'.
                      ADD 1 TO ld_reject.
                    WHEN '30'.
                      ADD 1 TO ld_an.
                    WHEN '40'.
                      ADD 1 TO ld_ap.
                  ENDCASE.
                ENDIF.
              ENDIF.
            ENDIF.

            LOOP AT t_qapp WHERE prueflos = prueflos AND
                                 vorglfnr = vorglfnr.
              IF t_qapp-vcode IS NOT INITIAL.
                ld_len = STRLEN( t_qapp-vcode ).
                ld_len = ld_len - 2.

                CASE t_qapp-vcode+ld_len(2).
                  WHEN '10'.
                    ADD 1 TO ld_accept.
                  WHEN '20'.
                    ADD 1 TO ld_reject.
                  WHEN '30'.
                    ADD 1 TO ld_an.
                  WHEN '40'.
                    ADD 1 TO ld_ap.
                ENDCASE.
              ENDIF.
            ENDLOOP.
          ELSE.
            READ TABLE t_qasr WITH KEY prueflos = prueflos
                                       vorglfnr = vorglfnr
                                       merknr   = merknr
            BINARY SEARCH.
            IF sy-subrc EQ 0.
              IF t_qasr-code1 IS NOT INITIAL.
                ld_len = STRLEN( t_qasr-code1 ).
                ld_len = ld_len - 2.

                CASE t_qasr-code1+ld_len(2).
                  WHEN '10'.
                    ADD 1 TO ld_confirm.
                  WHEN '20'.
                    ADD 1 TO ld_nonconf.
                ENDCASE.
              ENDIF.
            ENDIF.
            LOOP AT t_qapp WHERE prueflos = prueflos AND
                                 vorglfnr = vorglfnr.
              IF t_qapp-vcode IS NOT INITIAL.
                ld_len = STRLEN( t_qapp-vcode ).
                ld_len = ld_len - 2.

                CASE t_qapp-vcode+ld_len(2).
                  WHEN '10'.
                    ADD 1 TO ld_accept.
                  WHEN '20'.
                    ADD 1 TO ld_reject.
                  WHEN '30'.
                    ADD 1 TO ld_an.
                  WHEN '40'.
                    ADD 1 TO ld_ap.
                ENDCASE.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ELSE.
          READ TABLE t_qasr WITH KEY prueflos = prueflos
                                     vorglfnr = vorglfnr
                                     merknr   = merknr
          BINARY SEARCH.
          IF sy-subrc EQ 0.
            IF t_qasr-code1 IS NOT INITIAL.
              ld_len = STRLEN( t_qasr-code1 ).
              ld_len = ld_len - 2.

              CASE t_qasr-code1+ld_len(2).
                WHEN '10'.
                  ADD 1 TO ld_confirm.
                WHEN '20'.
                  ADD 1 TO ld_nonconf.
              ENDCASE.
            ENDIF.
          ENDIF.

          LOOP AT t_qapp WHERE prueflos = prueflos AND
                               vorglfnr = vorglfnr.
            IF t_qapp-vcode IS NOT INITIAL.
              ld_len = STRLEN( t_qapp-vcode ).
              ld_len = ld_len - 2.

              CASE t_qapp-vcode+ld_len(2).
                WHEN '10'.
                  ADD 1 TO ld_accept.
                WHEN '20'.
                  ADD 1 TO ld_reject.
                WHEN '30'.
                  ADD 1 TO ld_an.
                WHEN '40'.
                  ADD 1 TO ld_ap.
              ENDCASE.
            ENDIF.
          ENDLOOP.
        ENDIF.

      WHEN OTHERS.
        IF t_qase[] IS NOT INITIAL.
          LOOP AT t_qase WHERE prueflos = prueflos AND
                               vorglfnr = vorglfnr AND
                               merknr   = merknr.
            IF t_qase-mbewertg IS NOT INITIAL.
              CASE t_qase-mbewertg.
                WHEN 'A'.
                  ADD 1 TO ld_confirm.
                WHEN 'R'.
                  ADD 1 TO ld_nonconf.
              ENDCASE.
            ENDIF.
          ENDLOOP.
          IF sy-subrc EQ 0.
            LOOP AT t_qasr WHERE prueflos = prueflos AND
                                 vorglfnr = vorglfnr AND
                                 merknr   = merknr.
              IF t_qasr-code1 IS NOT INITIAL.
                ld_len = STRLEN( t_qasr-code1 ).
                ld_len = ld_len - 2.
                CASE t_qasr-code1+ld_len(2).
                  WHEN '10'.
                    ADD 1 TO ld_confirm.
                  WHEN '20'.
                    ADD 1 TO ld_nonconf.
                ENDCASE.
              ENDIF.

              IF t_qasr-mbewertg IS NOT INITIAL.
                IF t_qasr-code1 IS NOT INITIAL.
                  ld_len = STRLEN( t_qasr-code1 ).
                  ld_len = ld_len - 2.

                  CASE t_qasr-code1+ld_len(2).
                    WHEN '10'.
                      ADD 1 TO ld_accept.
                    WHEN '20'.
                      ADD 1 TO ld_reject.
                    WHEN '30'.
                      ADD 1 TO ld_an.
                    WHEN '40'.
                      ADD 1 TO ld_ap.
                  ENDCASE.
                ELSE.
                  READ TABLE t_qapp WITH KEY prueflos = prueflos
                                             vorglfnr = vorglfnr
                                             probenr  = t_qasr-probenr.
                  IF t_qapp-vcode IS NOT INITIAL.
                    ld_len = STRLEN( t_qapp-vcode ).
                    ld_len = ld_len - 2.

                    CASE t_qapp-vcode+ld_len(2).
                      WHEN '10'.
                        ADD 1 TO ld_accept.
                      WHEN '20'.
                        ADD 1 TO ld_reject.
                      WHEN '30'.
                        ADD 1 TO ld_an.
                      WHEN '40'.
                        ADD 1 TO ld_ap.
                    ENDCASE.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDLOOP.
          ELSE.
            LOOP AT t_qasr WHERE prueflos = prueflos AND
                                 vorglfnr = vorglfnr AND
                                 merknr   = merknr.
              IF t_qasr-mbewertg IS NOT INITIAL.
                CASE t_qasr-mbewertg.
                  WHEN 'A'.
                    ADD 1 TO ld_confirm.
                  WHEN 'R'.
                    ADD 1 TO ld_nonconf.
                ENDCASE.
              ENDIF.

              IF t_qasr-code1 IS NOT INITIAL.
                ld_len = STRLEN( t_qasr-code1 ).
                ld_len = ld_len - 2.
                CASE t_qasr-code1+ld_len(2).
                  WHEN '10'.
                    ADD 1 TO ld_accept.
                  WHEN '20'.
                    ADD 1 TO ld_reject.
                  WHEN '30'.
                    ADD 1 TO ld_an.
                  WHEN '40'.
                    ADD 1 TO ld_ap.
                ENDCASE.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ELSE.
          CASE case.
            WHEN 1.
              LOOP AT t_qasr WHERE prueflos = prueflos AND
                                   vorglfnr = vorglfnr AND
                                   merknr   = merknr.
                IF t_qasr-mbewertg IS NOT INITIAL.
                  CASE t_qasr-mbewertg.
                    WHEN 'A'.
                      ADD 1 TO ld_confirm.
                    WHEN 'R'.
                      ADD 1 TO ld_nonconf.
                  ENDCASE.
                ENDIF.
              ENDLOOP.

              LOOP AT t_qapp WHERE prueflos = prueflos AND
                                   vorglfnr = vorglfnr.
                IF t_qapp-vcode IS NOT INITIAL.
                  ld_len = STRLEN( t_qapp-vcode ).
                  ld_len = ld_len - 2.

                  CASE t_qapp-vcode+ld_len(2).
                    WHEN '10'.
                      ADD 1 TO ld_accept.
                    WHEN '20'.
                      ADD 1 TO ld_reject.
                    WHEN '30'.
                      ADD 1 TO ld_an.
                    WHEN '40'.
                      ADD 1 TO ld_ap.
                  ENDCASE.
                ENDIF.
              ENDLOOP.

            WHEN OTHERS.
              LOOP AT t_qasr WHERE prueflos = prueflos AND
                                   vorglfnr = vorglfnr AND
                                   merknr   = merknr.
                IF t_qasr-mbewertg IS NOT INITIAL.
                  CASE t_qasr-mbewertg.
                    WHEN 'A'.
                      ADD 1 TO ld_confirm.
                      ADD 1 TO ld_accept.
                    WHEN 'R'.
                      ADD 1 TO ld_nonconf.
                      ADD 1 TO ld_reject.
                  ENDCASE.
                ELSE.
                  IF t_qasr-code1 IS NOT INITIAL.
                    ld_len = STRLEN( t_qasr-code1 ).
                    ld_len = ld_len - 2.
                    CASE t_qasr-code1+ld_len(2).
                      WHEN '10'.
                        ADD 1 TO ld_confirm.
                      WHEN '20'.
                        ADD 1 TO ld_nonconf.
                    ENDCASE.
                  ENDIF.
                ENDIF.
              ENDLOOP.
          ENDCASE.
        ENDIF.
    ENDCASE.

    IF ld_flag IS INITIAL.
      IF ld_confirm IS NOT INITIAL.
        SHIFT ld_confirm LEFT DELETING LEADING space.
      ELSE.
        ld_confirm = '0'.
      ENDIF.
      IF ld_nonconf IS NOT INITIAL.
        SHIFT ld_nonconf LEFT DELETING LEADING space.
      ELSE.
        ld_nonconf = '0'.
      ENDIF.
      IF ld_accept IS NOT INITIAL.
        SHIFT ld_accept LEFT DELETING LEADING space.
      ELSE.
        ld_accept = '0'.
      ENDIF.
      IF ld_reject IS NOT INITIAL.
        SHIFT ld_reject LEFT DELETING LEADING space.
      ELSE.
        ld_reject = '0'.
      ENDIF.
      IF ld_an IS NOT INITIAL.
        SHIFT ld_an LEFT DELETING LEADING space.
      ELSE.
        ld_an = '0'.
      ENDIF.
      IF ld_ap IS NOT INITIAL.
        SHIFT ld_ap LEFT DELETING LEADING space.
      ELSE.
        ld_ap = '0'.
      ENDIF.

      IF ld_confirm NE '0' OR
        ld_nonconf NE '0' OR
        ld_accept NE '0' OR
        ld_reject NE '0' OR
        ld_an NE '0' OR
        ld_ap NE '0'.
        CONCATENATE ld_confirm 'sesuai/' INTO result SEPARATED BY space.
        CONCATENATE result ld_nonconf INTO result.
        CONCATENATE result 'tdk sesuai/' INTO result SEPARATED BY space.
        CONCATENATE ld_accept 'A' INTO ld_accept.
        CONCATENATE ld_reject 'R' INTO ld_reject.
        CONCATENATE ld_an 'AN' INTO ld_an.
        CONCATENATE ld_ap 'AP' INTO ld_ap.
        CONCATENATE result ld_accept INTO result.
        CONCATENATE result ld_reject ld_an ld_ap INTO result SEPARATED BY space.
      ENDIF.
    ELSEIF ld_flag = 1.
      IF ld_force IS NOT INITIAL.
        SHIFT ld_force LEFT DELETING LEADING space.
      ELSE.
        ld_force = '0'.
      ENDIF.
      CONCATENATE ld_force '/' t_qamr-mbewertg INTO result SEPARATED BY space.
    ELSEIF ld_flag = 2.
      IF ld_sesuai IS NOT INITIAL.
        result = ld_sesuai.
      ELSE.
        result = ld_tdksesuai.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFUNCTION.
