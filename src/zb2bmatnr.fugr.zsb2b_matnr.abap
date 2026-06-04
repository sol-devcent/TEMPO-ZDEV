FUNCTION zsb2b_matnr.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      PT_ZSH_B2B STRUCTURE  ZSH_B2B
*"      PT_ZSD_B2B STRUCTURE  ZSD_B2B
*"----------------------------------------------------------------------
  DATA : lt_mapb2b    TYPE STANDARD TABLE OF zsmap_b2b,
         ls_mapb2b    TYPE zsmap_b2b.

  IF pt_zsd_b2b[] IS NOT INITIAL.
    SELECT * INTO TABLE lt_mapb2b
      FROM zsmap_b2b FOR ALL ENTRIES IN pt_zsd_b2b
      WHERE material = pt_zsd_b2b-matnr
        AND vkbur    = pt_zsh_b2b-vkbur.
  ENDIF.

  IF lt_mapb2b[] IS NOT INITIAL.
    LOOP AT pt_zsh_b2b.
      LOOP AT pt_zsd_b2b WHERE znob2b = pt_zsh_b2b-znob2b.
        READ TABLE lt_mapb2b INTO ls_mapb2b
                             WITH KEY material = pt_zsd_b2b-matnr
                                      vkbur    = pt_zsh_b2b-vkbur.
        IF sy-subrc = 0.
          pt_zsd_b2b-matnr = ls_mapb2b-matnr.
          MODIFY pt_zsd_b2b TRANSPORTING matnr.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDIF.
ENDFUNCTION.
