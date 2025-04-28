FUNCTION fdg_proc_jiazhen, sid, ALLOW_MULTIPLE_MRIS=allow_multiple_mris, ANY_MRI=any_mri, ALLOW_OLD_MRI=allow_old_mri, PICK=pick, USE_PREVIOUS_MRI_ANYWAY=use_previous_mri_anyway

	COMPILE_OPT IDL2, HIDDEN

	IF N_ELEMENTS(allow_multiple_mris) EQ 0 THEN allow_multiple_mris=0
	IF N_ELEMENTS(allow_old_mri) EQ 0 THEN allow_old_mri=0
	IF N_ELEMENTS(any_mri) EQ 0 THEN any_mri=0
	IF N_ELEMENTS(use_previous_mri_anyway) EQ 0 THEN use_previous_mri_anyway=0

	sids_sum = []
	sids_bet = []
	injids = []
	ids_analysis = []
	FOR j = 0, n_elements(sid)-1 DO BEGIN
		esql=['vis.visitid,inj.patientstate']
		IF pick_series(SERID=sid[j],ROW=row,EXTRASQL=esql,TRACER='fdg',PAT='human') THEN BEGIN
			PRINT,'Seriesid ',sid[j],'not found'
			RETURN,1
		ENDIF
		injids = [injids, strtrim(row.injectionid,2)]
		; Create summed image
		serdesc=row.descrip
		mc_sid=sid
		mc_row = row

		sids_sum = [sids_sum, mc_sid]
		; Look up the ID of the BET image
		;2016-07-07 -jdg- moved that code in a subfunction
		IF lookup_mr_seriesid(betsid,betrow,LONG(row.visitid),row.startdatetime,row.patientid,row.protocol,LONG(row.studyid),ALLOW_MULTIPLE_MRIS=allow_multiple_mris,ALLOW_OLD_MRI=allow_old_mri,PICK=pick, USE_PREVIOUS_MRI_ANYWAY=use_previous_mri_anyway) THEN RETURN,1
		HELP,betsid
		sids_bet = [sids_bet, betsid]


		; MR to PET coregistration
		proc='flirt_mr_pet'
		; Look for registration to mc_pet
		vl = 'STDSPACE,RESLICESPACE,RESLICEID,STANDARDID'
		wc2 = 'STANDARDID_seriesid='+STRTRIM(betsid,2)+' and RESLICEID_seriesid='+STRTRIM(mc_sid,2)+' and STDSPACE_string="MR" and RESLICESPACE_string="PET"'
		IF qres(res,'xform_save',vl, wc2, SERIESID=mc_sid) THEN BEGIN
			PRINT,'Failed on lookup of registration from MR to PET'
			RETURN,1
		ENDIF
		IF res.number_rows EQ 0 THEN BEGIN
			PRINT,'Doing registration of MR to PET'
			IF flirt_mr_pet(mr_serid=betsid,pet_serid=mc_sid,/allslices,/wholevolume, PET_SPACE='PET',COST='mutualinfo') THEN BEGIN
				RETURN,1
			ENDIF
			PRINT,proc,' output sid:',mc_sid
		ENDIF ELSE IF long(res.number_rows) GT 1 THEN BEGIN
			PRINT,'Found several transforms of MR to PET in Haven. Analyses # are'+STRJOIN(STRTRIM(res.row.analysisid,2),', ')
			PRINT,' Cannot handle this case automatically.'
			RETURN,1
		ENDIF ELSE BEGIN
			PRINT,'Found MR-PET registration. Analysis # ',STRTRIM(res.row.analysisid,2)
		ENDELSE

		vl = 'STDSPACE,RESLICESPACE,RESLICEID,STANDARDID'
		wc2 = 'STANDARDID_seriesid='+STRTRIM(betsid,2)+' and RESLICEID_seriesid='+STRTRIM(mc_sid,2)+' and STDSPACE_string="MR" and RESLICESPACE_string="PET"'
		IF qres(res,'xform_save',vl, wc2, SERIESID=mc_sid) THEN BEGIN
			PRINT,'Failed on lookup of registration from MR to PET'
			RETURN,1
		ENDIF
		PRINT, check_transforms(transform_id=STRTRIM(res.row.analysisid,2))

	ENDFOR

	ids_analysis = [ids_analysis,STRTRIM(res.row.analysisid,2)]
	PRINT_IN_RED, 'injids='+strjoin(STRTRIM(injids,2),',')
	PRINT_IN_RED, 'ids_analysis='+strjoin(STRTRIM(ids_analysis,2),',')
	PRINT_IN_RED, 'sids_bet='+strjoin(STRTRIM(sids_bet,2),',')
	PRINT_IN_RED, 'sids_sum='+strjoin(STRTRIM(sids_sum,2),',')

	IF n_elements(injids) NE n_elements(ids_analysis) THEN STOP
	IF n_elements(injids) NE n_elements(sids_bet) THEN STOP
	IF n_elements(injids) NE n_elements(sids_sum) THEN STOP

	path_pattern = '^MR -\(L,6,[0-9]+\)- PET$'
	print, 'ser.studyid='+betrow.studyid
	; Compute regional average of SUV maps
	proc='do_mr_tac_v2 (1T_v6, 30 & 60 min, DV, K1)'
	roi=['FS_Frontal','FS_Occipital','FS_Parietal','FS_Temporal','FS_Insula','FS_Thalamus','FS_Caudate','FS_Putamen','FS_Pallidum','FS_Hippocampus','FS_Amygdala','FS_Cerebral_White_Matter','FS_Cerebellum_White_Matter','FS_Cerebellum_Cortex']
	curvenames_out=roi+'_yl_jnm2018_test' ; <-- you can remove '_yl_jnm2018_test'
	IF pick_series(labelmap_sid, SERDESC='FS_aparc_aseg', PAT=betrow.patientid, EXTRASQL='w ser.studyid='+betrow.studyid, /ALT) THEN STOP

	FOR i = 0, n_elements(sid)-1 DO BEGIN
		IF do_mr_tac_v2(SERID=sid[i],REG_SID=sids_sum[i],AAL=roi,PET_SPACE='PET',LABELMAP_SID=labelmap_sid,CURVENAME_OUT=curvenames_out,PATH_REGEX='FS_brain -(L,6,*)- MR -(L,6,'+strtrim(ids_analysis[i],2)+')- PET',/NO_GIF,/FIX_AAL,/QUIET,USE_TRILINEAR_INTERPOLATION=2) THEN BEGIN
			PRINT, 'Failure during execution of do_mr_tac_v2.'
			STOP
		ENDIF
	ENDFOR
	RETURN, 0
END					; end
