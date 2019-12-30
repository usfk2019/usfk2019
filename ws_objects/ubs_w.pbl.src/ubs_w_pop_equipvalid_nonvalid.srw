$PBExportHeader$ubs_w_pop_equipvalid_nonvalid.srw
$PBExportComments$[HMK] 장비인증 팝업 - 비인증(비연동)
forward
global type ubs_w_pop_equipvalid_nonvalid from w_a_hlp
end type
type dw_master from datawindow within ubs_w_pop_equipvalid_nonvalid
end type
type p_save from u_p_save within ubs_w_pop_equipvalid_nonvalid
end type
type dw_split from datawindow within ubs_w_pop_equipvalid_nonvalid
end type
type dw_detail from datawindow within ubs_w_pop_equipvalid_nonvalid
end type
type cb_next from commandbutton within ubs_w_pop_equipvalid_nonvalid
end type
type cb_pre from commandbutton within ubs_w_pop_equipvalid_nonvalid
end type
type p_reset from u_p_reset within ubs_w_pop_equipvalid_nonvalid
end type
type cb_1 from commandbutton within ubs_w_pop_equipvalid_nonvalid
end type
type st_1 from statictext within ubs_w_pop_equipvalid_nonvalid
end type
type gb_1 from groupbox within ubs_w_pop_equipvalid_nonvalid
end type
end forward

global type ubs_w_pop_equipvalid_nonvalid from w_a_hlp
integer width = 3131
integer height = 1412
string title = ""
event ue_processvalidcheck ( ref integer ai_return )
event ue_inputvalidcheck ( ref integer ai_return )
event ue_process ( ref integer ai_return )
event type long ue_retrieve_left ( )
event type long ue_retrieve_right ( )
event ue_reset ( )
dw_master dw_master
p_save p_save
dw_split dw_split
dw_detail dw_detail
cb_next cb_next
cb_pre cb_pre
p_reset p_reset
cb_1 cb_1
st_1 st_1
gb_1 gb_1
end type
global ubs_w_pop_equipvalid_nonvalid ubs_w_pop_equipvalid_nonvalid

type variables
u_cust_db_app iu_cust_db_app

STRING 	is_print_check, 	is_amt_check, 	is_customerid, 	is_phone_type, 	&
       	is_paycod,			is_format,		is_reqdt,		 	is_method[], 		&
		   is_trcod[],			is_save_check,	is_work
DATE 	 	idt_shop_closedt
DOUBLE	ib_seq
DEC{2} 	idc_amt[], 			idc_total, 		idc_income_tot
INTEGER 	ii_method_cnt,		ii_equipselect = 0

STRING	is_orderno,			is_partner,			is_userid,			&
			is_rental700[],	is_rental800[],	is_rental900[],	&
			is_old_sql,			is_priceplan,		is_svccod,			&
			is_vocm,				is_ref_orderno,	is_status,			&
			is_gubunnm,			is_worktype,		is_troubleno,		&
			is_wifi[],			is_equipdate,		is_bad_status,		&
			is_contractseq
	

end variables

forward prototypes
public subroutine wf_set_total ()
public function integer wf_split (date paydt)
public function integer wf_action_code2 (string as_work, ref string as_code)
public function integer wf_equip_chg_clear (string data_check, string data_all, integer data_row)
public function integer wf_action_code (ref string as_code)
public function integer wf_equip_clear (string data_check, string data_all, integer data_row)
end prototypes

event ue_inputvalidcheck(ref integer ai_return);BOOLEAN lb_check
LONG    ll_row

ll_row = dw_hlp.GetRow()

lb_check = fb_save_required(dw_hlp, ll_row)

IF lb_check = FALSE THEN
	ai_return = -1
END IF

RETURN
end event

event ue_process(ref integer ai_return);
STRING	ls_data_check,		  ls_errmsg,			ls_action,			   ls_adtype,			&
			ls_first_adtype,	  ls_second_adtype,	ls_work,				   ls_spec_item1,		&
			ls_data_chk_gg,	  ls_spec_item_gg,	ls_action_gg, 		   ls_work_gg,			&
			ls_adtype_gg,	 	  ls_adtype_w,       ls_del_status,       ls_status,        &
			ls_spec_item2
LONG		ll_equipseq,		  ll_return,		   ll_row,				   ll_return2,       &
         ll_contractseq_ins, ll_cust_no_ins,    ll_contractseq_ins2, ll_cust_no_ins2
LONG		ll_contractseq,	  ll_insert_equip,	ll_row_det
INT		ii,					  iii,					jj,					   cc, 					&
			gg,					  g,						r
LONG		ll_insert_case,	  ll_retrie_case,	   ll_delete_case,	   ll_etc_case,	   &
         ll_equip_gg,        ll_return_c,		   ll_delete_gg,		   ll_insert_gg,     &
		   ll_equipseq_w,      ll_func_check,		ll_func_chg_check
			
LONG     ll_ap_cnt  , ll_phone_cnt = 0			

dw_detail.AcceptText()

ll_row = dw_detail.RowCount()

IF ll_row <= 0 THEN
	f_msg_usr_err(9000, Title, "임대/예약중 장비가 없습니다.")
	ai_return = -1
	ROLLBACK;
	RETURN	
END IF

// 2009.06.12 로직 추가! 다양한 유형 때문에...
// 케이스 정리
FOR jj = 1 TO ll_row
	ls_data_check = dw_detail.Object.data_check[jj]
	
	CHOOSE CASE ls_data_check
		CASE "I"
			ll_insert_case = ll_insert_case + 1
		CASE "R"
			ll_retrie_case = ll_retrie_case + 1
		CASE "D"
			ll_delete_case = ll_delete_case + 1			
		CASE ELSE
			ll_etc_case    = ll_etc_case + 1
	END CHOOSE
NEXT

IF ll_insert_case > 0 THEN
	IF ll_retrie_case > 0 THEN
		IF ll_delete_case > 0 THEN
			IF is_worktype = "100" THEN					//신규 장비 교체
				is_work = "CHANGE2"						//WIFI 땜에...			
			ELSE
				is_work = "CHANGE"						//WIFI 땜에...
			END IF
		ELSE
			is_work = "ADD"						//추가 작업
		END IF
	ELSEIF ll_delete_case > 0 THEN
		IF is_worktype = "100" THEN
			is_work = "CHANGE2"					//변경 작업
		ELSE
			is_work = "CHANGE"
		END IF
	ELSE
		is_work = "INSERT"					//신규 작업
	END IF
ELSE
	IF ll_retrie_case > 0 THEN
		IF ll_delete_case > 0 THEN
			is_work = "DELETE2"				//일부장비 삭제 작업
		ELSE

				is_work = "RETRY"				//RETRY
	
		END IF
	ELSE
		IF ll_delete_case > 0 THEN
			is_work = "DELETE"					//삭제 작업
		ELSE
			is_work = "NOWORK"				//NO WORK
		END IF
	END IF
END IF

//2009.06.12 로직 추가! 다양한 유형 때문에...END
IF is_work = "NOWORK" THEN
	f_msg_usr_err(9000, Title, "작업할 내용이 없습니다. 확인하세요.")
	ai_return = -1		
	RETURN
END IF		

IF is_worktype = "100" AND is_work = "CHANGE" THEN
	f_msg_usr_err(9000, Title, "입력장비를 제거후 저장하신후 다시 작업하세요.")
	ai_return = -1		
	RETURN
END IF	





//IF is_worktype = "100" AND is_work = "INSERT" THEN
//	IF	ll_insert_case = 1 THEN		
//
//		ll_equipseq_w = dw_detail.Object.equipseq[1]
//		
//		SELECT ADTYPE INTO :ls_adtype_w
//		FROM   EQUIPMST
//		WHERE  EQUIPSEQ = :ll_equipseq_w;
//		
//
//			UPDATE EQUIPMST
//			SET    STATUS 	    = :is_rental900[1],
//					 CUSTOMERID  = NULL,
//					 ORDERNO	    = NULL,
//					 CONTRACTSEQ = NULL,
//					 CUST_NO     = NULL
//			WHERE  EQUIPSEQ    = :ll_equipseq_w;
//
//			IF SQLCA.SQLCODE <> 0 THEN		//For Programer
//				ai_return = -1
//				ROLLBACK;
//				RETURN
//			ELSE
//				ai_return = -2
//				COMMIT;
//			END IF
//			
//			RETURN
//			
//
//	END IF	
//END IF		
		
		
		
//장비수 확인!!!
FOR iii = 1 TO ll_row
	ls_data_check = dw_detail.Object.data_check[iii]
	ll_equipseq   = dw_detail.Object.equipseq[iii]

	
	IF ls_data_check = "I" OR ls_data_check = "R" THEN
		ll_insert_equip = ll_insert_equip + 1
		
		SELECT ADTYPE INTO :ls_adtype
		FROM   EQUIPMST
		WHERE  EQUIPSEQ = :ll_equipseq;
		
		IF ll_insert_equip = 1 THEN
			ls_first_adtype = ls_adtype
		ELSE
			ls_second_adtype = ls_adtype		
		END IF				
	END IF
 
  
	IF ll_insert_equip > 2 THEN
		f_msg_usr_err(9000, Title, "선택할 수 있는 장비수를 초과했습니다.")
		
		ll_func_check = wf_equip_clear("I", "A", 0)				//장비 원복
		
		IF ll_func_check < 0 THEN
			ai_return = -1
		ELSE
			ai_return = -2
		END IF
		RETURN
	END IF

	IF ll_insert_equip = 2 THEN
		IF IsNull(ls_second_adtype) = FALSE OR ls_second_adtype <> "" THEN
			IF ls_first_adtype = ls_second_adtype THEN
				f_msg_usr_err(9000, Title, "같은 타입의 장비를 선택하셨습니다.")
				
				ll_func_check = wf_equip_clear("I", "A", 0)				//장비 원복
				
				IF ll_func_check < 0 THEN
					ai_return = -1
				ELSE
					ai_return = -2
				END IF				
				RETURN			
			END IF			
		END IF
	END IF
	

NEXT



 IF is_worktype = '200' AND (IsNull(is_troubleno) OR is_troubleno <> "") THEN   //장애 
	
	IF ll_insert_case <> ll_delete_case THEN
		f_msg_usr_err(9000, Title, "삭제장비와 추가장비의 개수가 동일해야 합니다.")
		
		ll_func_check = wf_equip_clear("I", "A", 0)				//장비 원복
		
		IF ll_func_check < 0 THEN
			ai_return = -1
		ELSE
			ai_return = -2
		END IF
		
		RETURN
	END IF		
	
	is_orderno = is_troubleno
	//장비(단말) 변경일 경우에 기존장비, 신규장비 관련 값을 기록으로 남긴다. 프로시저 처리를 원할히 위해서.
	SELECT CONTRACTSEQ INTO :ll_contractseq   FROM CUSTOMER_TROUBLE
	WHERE  TROUBLENO = TO_NUMBER(:is_troubleno);
	
	FOR ii = 1 TO ll_row
		ls_data_check = dw_detail.Object.data_check[ii]
		ll_equipseq   = dw_detail.Object.equipseq[ii]
		
		IF ls_data_check = "D" OR ls_data_check = "I" THEN		
			INSERT INTO EQUIP_CHANGE
			 (EQUIPSEQ    , TROUBLENO               , CONTRACTSEQ, 
			  CHANGE_TYPE , 
			  TIMESTAMP   , STATUS                  ,	MAC_ADDR      , MAC_ADDR2, SERIALNO, CONTNO, 
			  DACOM_MNG_NO, CRT_USER                , UPDT_USER     , CRTDT    , UPDTDT   , 
			  PGM_ID      , ADTYPE                  , PROVISION_FLAG )
			SELECT 
			  EQUIPSEQ    , TO_NUMBER(:is_troubleno), :ll_contractseq, 
			  DECODE(:ls_data_check, 'R', 'O', 'D', 'O', 'N'),
			  ''          , STATUS                  , MAC_ADDR       , MAC_ADDR2, SERIALNO, CONTNO, 
			  DACOM_MNG_NO, :gs_user_id             , :gs_user_id    , SYSDATE  , SYSDATE,
			  'NONVALID'  , ADTYPE                  , NULL
			FROM   EQUIPMST
			WHERE  EQUIPSEQ = :ll_equipseq;
	
			IF SQLCA.SQLCODE <> 0 THEN		
				MESSAGEBOX(ls_errmsg, STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
				
				ll_func_check = wf_equip_clear("I", "A", 0)				//장비 원복
			
				IF ll_func_check < 0 THEN
					ai_return = -1
				ELSE
					ai_return = -2
				END IF

				RETURN
			END IF		
		END IF	
	NEXT
END IF



SetNull(ll_equipseq)

p_save.TriggerEvent("ue_disable")
dw_hlp.Enabled = False


IF is_work = "ADD" OR is_work = "INSERT" OR is_work = "CHANGE" OR is_work = "DELETE" THEN
	
	is_save_check = 'Y'
	
	IF is_equipdate = 'Y' THEN					//신규 장비교체(삭제장비 원복)
		ll_func_chg_check = wf_equip_chg_clear("D1", "A", 0)				//장비 원복
		
		IF ll_func_chg_check < 0 THEN
			ai_return = -1
			RETURN
		END IF
	ELSEIF is_equipdate = 'X' THEN			//장애 장비교체(삭제장비 원복)
		ll_func_chg_check = wf_equip_chg_clear("D2", "A", 0)				//장비 원복
		
		IF ll_func_chg_check < 0 THEN
			ai_return = -1
			RETURN
		END IF		
	END IF	
		
	
	
	IF is_worktype = '100' OR is_worktype = '200' THEN
		FOR cc = 1 TO ll_row
			ll_equipseq        = dw_detail.Object.equipseq[cc]
			ls_data_check      = dw_detail.Object.data_check[cc]
			ll_contractseq_ins = dw_detail.Object.contractseq[cc]
			ll_cust_no_ins     = dw_detail.Object.cust_no[cc]
			IF ls_data_check = 'D' THEN  // 신규/삭제 건 (A/S 인 경우) // 2012.6.21 lsh - 삭제 당시의 contract, cust_no
				ll_contractseq_ins2 = ll_contractseq_ins
				ll_cust_no_ins2  = ll_cust_no_ins
				ls_del_status = 'Y'
			end if
			IF ls_data_check = 'I' THEN
				//신규인증중으로 UPDATE
				UPDATE EQUIPMST
				SET    VALID_STATUS = '200'
				WHERE  EQUIPSEQ = :ll_equipseq;

				IF SQLCA.SQLCODE < 0 THEN		//For Programer
					ai_return = -1		
					ROLLBACK;
					RETURN
				END IF
			END IF
			
			IF ls_del_status = 'Y' and ls_data_check = 'I' THEN // 삭제가 있으면서 I가 있을 때만 처리 contractseq와 cust_no를 처리
				//신규인증중으로 UPDATE
				UPDATE EQUIPMST
				SET    VALID_STATUS = '200',
				       CONTRACTSEQ  = :ll_contractseq_ins2 ,
						 CUST_NO      = :ll_cust_no_ins2
				WHERE  EQUIPSEQ = :ll_equipseq;

				IF SQLCA.SQLCODE < 0 THEN		//For Programer
					ai_return = -1		
					ROLLBACK;
					RETURN
				END IF
			END IF
			
  
         IF ls_del_status = 'Y' and ls_data_check = 'D' THEN 
				
				UPDATE EQUIPMST
				SET    VALID_STATUS = '900' //해지인증완료 
				WHERE  EQUIPSEQ = :ll_equipseq;

				IF SQLCA.SQLCODE < 0 THEN		//For Programer
					ai_return = -1		
					ROLLBACK;
					RETURN
				END IF
			END IF			
            
			/**************************************************************************************/	
			
		NEXT
	END IF
ELSEIF is_work = "CHANGE2" THEN				//신규 장비 인증일 경우
	ll_row_det = dw_detail.RowCount()
	
	FOR gg = 1 TO ll_row_det
		ls_data_chk_gg  = dw_detail.Object.data_check[gg]
		ll_equip_gg     = dw_detail.Object.equipseq[gg]
		ls_spec_item_gg = dw_detail.Object.spec_item1[gg]	
		
		SELECT ADTYPE INTO :ls_adtype_gg
		FROM   EQUIPMST
		WHERE  EQUIPSEQ = :ll_equip_gg;
		
		IF ls_data_chk_gg = "D" THEN
			ls_work_gg = "DELETE"
		ELSEIF ls_data_chk_gg = "I" THEN
			ls_work_gg = "INSERT"
		END IF
		
		IF ls_adtype_gg = is_wifi[1] OR  ls_adtype_gg = is_wifi[2] THEN
			IF ls_data_chk_gg = "D" OR ls_data_chk_gg = "I" THEN			//삭제 또는 신규일 때....
					is_save_check = 'Y'
			END IF
			
			IF ls_data_chk_gg = "D" THEN				//삭제일 때만
			
				IF is_equipdate = 'Y' THEN					//신규 장비교체(삭제장비 처리)
					ll_func_chg_check = wf_equip_chg_clear("D1", "R", gg)				//장비 처리
					
					IF ll_func_chg_check < 0 THEN
						ai_return = -1
						return
					END IF
				ELSEIF is_equipdate = 'X' THEN			//장애 장비교체(삭제장비 처리)
					ll_func_chg_check = wf_equip_chg_clear("D2", "R", gg)				//장비 처리
					
					IF ll_func_chg_check < 0 THEN
						ai_return = -1
						return
					END IF		
				END IF	
			END IF
			
			//자급장비로 들어온 경우 자급장비 이력을 지운다. 이게 예외로 들어온 놈이라서...에휴...
			//spec_item1 에 'Y' 인 경우만 신규인증 받도록 하기 위해서!
			IF ls_spec_item_gg = 'Y' THEN
				
				UPDATE EQUIPMST
				SET    SPEC_ITEM1 = NULL,
				       SPEC_ITEM2 = 'SELF_INPUT_DELETE'	
				WHERE  EQUIPSEQ  = :ll_equip_gg;
			
				IF SQLCA.SQLCODE <> 0 THEN		//For Programer
					ai_return = -1		
					RETURN
				END IF
			END IF
		
			IF is_worktype = '100' THEN
				IF ls_data_chk_gg = 'I' THEN
					//신규인증중으로 UPDATE
					UPDATE EQUIPMST
					SET    VALID_STATUS = '200'
					WHERE  EQUIPSEQ = :ll_equip_gg;
		
					IF SQLCA.SQLCODE < 0 THEN		//For Programer
						ai_return = -1		
						RETURN
					END IF
				END IF
			END IF	
 
			
			IF  ls_data_chk_gg = 'D' THEN
				 UPDATE  EQUIPMST
				    SET  VALID_STATUS = '900' //해지인증완료 
			  	  WHERE  EQUIPSEQ = :ll_equip_gg;
	
				   IF SQLCA.SQLCODE < 0 THEN		//For Programer
						ai_return = -1		
						ROLLBACK;
						RETURN
					END IF
			   END IF			
            
			/**************************************************************************************/			
			
			COMMIT;

		ELSE		
			IF ls_data_chk_gg = "D" OR ls_data_chk_gg = "I" THEN			//삭제 또는 신규일 때....

				is_save_check = 'Y'
			END IF
			
			IF ls_data_chk_gg = "D" THEN
			
				IF is_equipdate = 'Y' THEN					//신규 장비교체(삭제장비 처리)
					ll_func_chg_check = wf_equip_chg_clear("D1", "R", gg)				//장비처리
					
					IF ll_func_chg_check < 0 THEN
						ai_return = -1
						return
					END IF
				ELSEIF is_equipdate = 'X' THEN			//장애 장비교체(삭제장비 처리)
					ll_func_chg_check = wf_equip_chg_clear("D2", "R", gg)				//장비처리
					
					IF ll_func_chg_check < 0 THEN
						ai_return = -1
						return
					END IF		
				END IF
			END IF
		
			//자급장비로 들어온 경우 자급장비 이력을 지운다. 이게 예외로 들어온 놈이라서...에휴...
			//spec_item1 에 'Y' 인 경우만 신규인증 받도록 하기 위해서!
			IF ls_spec_item_gg = 'Y' THEN
				UPDATE EQUIPMST
				SET    SPEC_ITEM1 = NULL,
			          SPEC_ITEM2 = 'SELF_INPUT_DELETE'	
				WHERE  EQUIPSEQ  = :ll_equip_gg;
			
				IF SQLCA.SQLCODE <> 0 THEN		//For Programer
					ai_return = -1	
					ROLLBACK;
					RETURN
				END IF
			END IF
		
			IF is_worktype = '100' OR is_worktype = '200' THEN
				IF ls_data_chk_gg = 'I' THEN
					//신규인증중으로 UPDATE
					UPDATE EQUIPMST
					SET    VALID_STATUS = '200'
					WHERE  EQUIPSEQ = :ll_equip_gg;
		
					IF SQLCA.SQLCODE < 0 THEN		//For Programer
						ai_return = -1	
						ROLLBACK;
						RETURN
					END IF
				END IF			
				
				
			
				IF  ls_data_chk_gg = 'D' THEN
					UPDATE EQUIPMST
					SET    VALID_STATUS = '900' //해지인증완료 
					WHERE  EQUIPSEQ = :ll_equip_gg;
	
					IF SQLCA.SQLCODE < 0 THEN		//For Programer
						ai_return = -1		
						ROLLBACK;
						RETURN
					END IF
			   END IF			
            
			/**************************************************************************************/
				
			END IF
						
			COMMIT;
			
		END IF
	NEXT		
END IF



FOR ii = 1 TO ll_row
	
ll_equipseq        = dw_detail.Object.equipseq[ii]

Select  status,    spec_item2
  into :ls_status, :ls_spec_item2
From Equipmst
Where Equipseq = :ll_equipseq;

If ls_status = '200' And ls_spec_item2 = 'SELF_INPUT_DELETE' Then

	UPDATE EQUIPMST
  		SET STATUS = '900' , //해지인증완료
   	    Spec_item1 = 'Y' ,
       	 Spec_item2 = null 
	WHERE  EQUIPSEQ = :ll_equipseq
     And  STATUS = '200' ;
  
	IF SQLCA.SQLCODE < 0 THEN		//For Programer
		ai_return = -1		
		ROLLBACK;
		RETURN
	END IF

END IF;	

NEXT	

//수정된 내용이 없도록 하기 위해서 강제 세팅!

FOR ii = 1 TO ll_row
	dw_detail.SetItemStatus(ii, 0, Primary!, NotModified!)
NEXT

COMMIT;
ai_return = 0

RETURN
end event

event type long ue_retrieve_left();STRING	ls_modelno,			ls_searchno,		ls_shop,		ls_new_sql,		&
			ls_status_where,	ls_new_sql2,      ls_login_group,  ls_login_id,  &
			ls_login_filter
			
INT     li_i,					li_exist, li_cnt


dw_hlp.AcceptText()
ls_modelno	= Trim(dw_hlp.object.modelno[1])
ls_searchno = dw_hlp.object.searchno[1]
ls_shop		= Trim(dw_hlp.object.shop[1])

IF IsNull(ls_modelno)  OR ls_modelno  = ""  THEN RETURN 0
IF IsNull(ls_searchno) OR ls_searchno = "" THEN ls_searchno = ""
IF IsNull(ls_shop) 	  OR ls_shop = "" 	 THEN ls_shop = ""


ls_status_where = ""

FOR li_i = 1 TO UpperBound(is_rental700[])
	IF ls_status_where <> ""  THEN ls_status_where += ", "
	ls_status_where += "'" + is_rental700[li_i] + "'"
NEXT

ls_new_sql = " WHERE STATUS IN (" + ls_status_where + ") "	

 ls_new_sql += " AND SN_PARTNER = '" + gs_user_group + "' "


IF ls_modelno <> "" THEN
	ls_new_sql += " AND MODELNO = '" + ls_modelno + "' "
END IF

IF ls_searchno <> "" THEN
	ls_new_sql += " AND ( DACOM_MNG_NO = UPPER('" + ls_searchno + "') OR SERIALNO = UPPER('" + ls_searchno + "') OR MAC_ADDR = LOWER('" + ls_searchno + "')) "
END IF


ls_new_sql2 = is_old_sql + ls_new_sql

dw_master.SetSQLSelect(ls_new_sql2)

IF ls_shop = gs_user_group Then   //2013.12.26 김선주 ADD
	li_exist =dw_master.Retrieve()
	
	If li_exist < 0 Then 				
		f_msg_usr_err(2100, Title, "Retrieve()")
		Return 1  	
	End If
END IF 

RETURN 0
end event

event type long ue_retrieve_right();STRING	ls_modelno,			ls_searchno,		ls_shop
INT		li_exist
STRING   ls_status_where,	ls_old_sql,		ls_new_sql, ls_customerid, ls_contractseq 

ls_modelno	= Trim(dw_hlp.object.modelno[1])
ls_searchno = dw_hlp.object.searchno[1]
ls_shop		= Trim(dw_hlp.object.shop[1])

IF IsNull(ls_modelno)  OR ls_modelno = ""  THEN ls_modelno = ""
IF IsNull(ls_searchno) OR ls_searchno = "" THEN ls_searchno = ""
IF IsNull(ls_shop) 	  OR ls_shop = "" 	 THEN ls_shop = ""

ls_status_where = ""
ls_old_sql = "SELECT  DECODE(SALE_FLAG, '0', DACOM_MNG_NO||':'||MAC_ADDR, '1', SERIALNO||':'||MAC_ADDR) AS RENTAL_EQUIP " +&
			 ", EQUIPSEQ , DECODE(SPEC_ITEM1, 'Y', 'I', 'R') AS DATA_CHECK, SPEC_ITEM1, 'N' AS NEW_CHECK, CONTRACTSEQ, CUST_NO , ADTYPE " +&
			 "FROM    EQUIPMST " 			 
		 

IF is_worktype <> '100' AND is_worktype <> '400' THEN				//신규, auto가 아닐경우	
	SELECT CUSTOMERID, CONTRACTSEQ INTO :ls_customerid, :ls_contractseq 
	FROM   CUSTOMER_TROUBLE 
	WHERE  TROUBLENO = TO_NUMBER(:is_troubleno);
	
	IF IsNull(is_troubleno) = FALSE OR is_troubleno <> "" THEN
		ls_new_sql = " WHERE CONTRACTSEQ = '" + ls_contractseq + "' "
	ELSE	
		ls_new_sql = " WHERE ORDERNO = TO_NUMBER('" + is_orderno + "') "				
	END IF
ELSE
	ls_new_sql = " WHERE ORDERNO = TO_NUMBER('" + is_orderno + "') "						
END IF


ls_status_where = ls_old_sql + ls_new_sql

dw_detail.SetSqlSelect(ls_old_sql + ls_new_sql)

li_exist =dw_detail.Retrieve()
	
If li_exist < 0 Then 				
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return 1  	
End If  

RETURN 0

end event

event ue_reset;STRING	ls_data_check
LONG		ll_equipseq
INT		ii

dw_detail.AcceptText()

IF is_save_check = 'N' THEN
	FOR ii = 1 TO dw_detail.RowCount()
		ls_data_check = dw_detail.Object.data_check[ii]
		ll_equipseq   = dw_detail.Object.equipseq[ii]
		
		IF ls_data_check = "I"	THEN
			UPDATE EQUIPMST
			SET    STATUS      = :is_rental900[1],
					 CUSTOMERID  = NULL,
					 ORDERNO     = NULL,
					 CONTRACTSEQ = NULL,
					 CUST_NO     = NULL
			WHERE  EQUIPSEQ    = :ll_equipseq;
			
			IF SQLCA.SQLCODE <> 0 THEN		//For Programer
				f_msg_usr_err(9000, Title, "장비 원복에 실패했습니다.")
				ROLLBACK;
				RETURN
			ELSE
				COMMIT;
			END IF																			
		END IF		
	NEXT
END IF

dw_master.Reset()
dw_detail.Reset()

//dw_master.Retrieve()
dw_detail.Retrieve()
end event

public subroutine wf_set_total ();DEC{2}	ldc_TOTAL

ldc_total = 0

IF dw_master.RowCount() > 0 THEN
	ldc_total = dw_master.GetItemNumber(dw_master.RowCount(), "all_sum") 
END IF

dw_hlp.Object.total[1] 		= ldc_total

//
F_INIT_DSP(2, "", String(ldc_total))

RETURN
end subroutine

public function integer wf_split (date paydt);
RETURN 0
end function

public function integer wf_action_code2 (string as_work, ref string as_code);IF IsNull(is_status)  OR is_status  = ""  THEN RETURN -1
IF IsNull(is_gubunnm) OR is_gubunnm = ""  THEN RETURN -1
IF IsNull(as_work)    OR as_work 	= "" 	THEN RETURN -1

CHOOSE CASE is_status
	CASE '10'			//신규신청
		IF as_work = "DELETE" THEN
			IF is_gubunnm = "전화" THEN
				as_code = "TEL800"
			ELSE
				as_code = "INT800"
			END IF
		ELSEIF as_work = "INSERT" THEN
			IF is_gubunnm = "전화" THEN
				as_code = "TEL100"
			ELSE
				as_code = "INT100"
			END IF
		END IF

END CHOOSE		

return 0
end function

public function integer wf_equip_chg_clear (string data_check, string data_all, integer data_row);STRING	ls_data_check,		ls_status,		ls_new_check,		ls_action
LONG		ll_row,				ll_equipseq,	ll_days
INT		ii

dw_detail.AcceptText()

ll_row = dw_detail.RowCount()

//로그 행위(action)추출 - 인증
SELECT ref_content		INTO :ls_action		FROM sysctl1t 
WHERE module = 'U3' AND ref_no = 'A108';	

IF data_check = "D1" THEN
	ls_status = is_rental900[1]
ELSEIF data_check = "D2" THEN
	ls_status = is_bad_status
END IF

IF data_check = "D1" OR data_check = "D2" THEN						//신규 삭제일 경우에는 예비로 장비를 돌린다.
	IF data_all = "A" THEN													//신규 삭제 전체 정리
		FOR ii = 1 TO ll_row
			ls_data_check = dw_detail.Object.data_check[ii]
			ll_equipseq	  = dw_detail.Object.equipseq[ii]
		
			IF ls_data_check = "D" THEN		//삭제인 놈만 정리
			
				SELECT TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD') - 
						 TO_DATE(TO_CHAR(NVL(FIRST_SALEDT, TO_DATE('20090701', 'YYYYMMDD')),'YYYYMMDD'), 'YYYYMMDD')
				INTO   :ll_days
				FROM   EQUIPMST
				WHERE  EQUIPSEQ = :ll_equipseq;
				
				IF ll_days <= 14 THEN
					ls_new_check = 'Y'
				ELSE
					ls_new_check = 'N'
				END IF
				
				IF ls_new_check = 'Y' THEN
					UPDATE EQUIPMST
					SET    STATUS 	    = :ls_status,
							 NEW_YN		 = 'Y',					 
							 USE_CNT     = USE_CNT - 1,
							 CUSTOMERID  = NULL,
							 ORDERNO	    = NULL,
							 CONTRACTSEQ = NULL,
							 CUST_NO     = NULL,
							 FIRST_CUSTOMER 	= NULL,
							 FIRST_SALEDT 		= NULL,
							 FIRST_SELLER 		= NULL,
							 FIRST_PARTNER 	= NULL,
							 FIRST_SALE_AMT 	= NULL,						 							 
							 UPDT_USER   = :gs_user_id,
							 UPDTDT		 = SYSDATE						 
					WHERE  EQUIPSEQ    = :ll_equipseq;				
				ELSE					
					UPDATE EQUIPMST
					SET    STATUS 	    = :ls_status,
							 CUSTOMERID  = NULL,
							 ORDERNO	    = NULL,
							 CONTRACTSEQ = NULL,
							 CUST_NO     = NULL,
							 UPDT_USER   = :gs_user_id,
							 UPDTDT		 = SYSDATE						
					WHERE  EQUIPSEQ    = :ll_equipseq;											 
				END IF
				
				IF SQLCA.SQLCODE <> 0 THEN		//For Programer
					f_msg_usr_err(9000, Title, "장비 원복에 실패했습니다.")
					ROLLBACK;
					RETURN -1
				ELSE
					//INSERT EQUIPLOG
					INSERT INTO EQUIPLOG
					(EQUIPSEQ,		SEQ,				LOGDATE,		LOG_STATUS,		SERIALNO,
					 CONTNO,			DACOM_MNG_NO,	MAC_ADDR,	MAC_ADDR2,		ADTYPE,
					 MAKERCD,		MODELNO,			STATUS,		VALID_STATUS,	USE_YN,
					 ADSTAT,			IDATE,			ISEQNO,		ENTSTORE,		MOVENO,
					 MV_PARTNER,	TO_PARTNER,		SN_PARTNER,	SNMOVEDT,		SALEDT,
					 RETDT,			CUSTOMERID,		CONTRACTSEQ,ORDERNO,			CUST_NO,
					 IDAMT,   	   SALE_AMT,		ITEMCOD,		SALE_FLAG,		REMARK,
					 SAP_NO,		 	NEW_YN,			USE_CNT,    CRT_USER,		CRTDT,
					 PGM_ID,			TROUBLE_CAUSE,	FIRST_CUSTOMER, FIRST_SALEDT, FIRST_SELLER,
					 FIRST_PARTNER, FIRST_SALE_AMT, CHANGE_REASON)
					SELECT EQUIPSEQ,	SEQ_EQUIPLOG.NEXTVAL,	SYSDATE, 	:ls_action, 	SERIALNO,
							 CONTNO,		DACOM_MNG_NO,				MAC_ADDR,	MAC_ADDR2,		ADTYPE,
							 MAKERCD,	MODELNO,						STATUS,		VALID_STATUS,	USE_YN,
							 ADSTAT,			IDATE,			ISEQNO,		ENTSTORE,		MOVENO,
							 MV_PARTNER,	TO_PARTNER,		SN_PARTNER,	SNMOVEDT,		SALEDT,
							 RETDT,			CUSTOMERID,		CONTRACTSEQ,ORDERNO,			CUST_NO,
							 IDAMT,   	   SALE_AMT,		ITEMCOD,		SALE_FLAG,		REMARK,			  
							 SAP_NO,		 	NEW_YN,			USE_CNT,    :gs_user_id,	SYSDATE,
							 :gs_pgm_id[gi_open_win_no],  TROUBLE_CAUSE,	FIRST_CUSTOMER, FIRST_SALEDT, FIRST_SELLER,
							 FIRST_PARTNER, FIRST_SALE_AMT, CHANGE_REASON
					FROM   EQUIPMST
					WHERE  EQUIPSEQ = :ll_equipseq;					
					
					IF SQLCA.SQLCODE <> 0 THEN		//For Programer
						f_msg_usr_err(9000, Title, "장비 원복에 실패했습니다.")
						ROLLBACK;
						RETURN -1
					ELSE							
						COMMIT;
					END IF
				END IF														
			END IF
		NEXT
	ELSE												//신규 일부 정리 ( row 받음 )
		ls_data_check = dw_detail.Object.data_check[data_row]
		ll_equipseq	  = dw_detail.Object.equipseq[data_row]	
	
		IF ls_data_check = "D" THEN
			SELECT TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD') - 
					 TO_DATE(TO_CHAR(NVL(FIRST_SALEDT, TO_DATE('20090701', 'YYYYMMDD')),'YYYYMMDD'), 'YYYYMMDD')
			INTO   :ll_days
			FROM   EQUIPMST
			WHERE  EQUIPSEQ = :ll_equipseq;
			
			IF ll_days > 14 THEN
				ls_new_check = 'Y'
			ELSE
				ls_new_check = 'N'			
			END IF					
			
			IF ls_new_check = 'Y' THEN
				UPDATE EQUIPMST
				SET    STATUS 	    = :ls_status,
						 NEW_YN		 = 'Y',					 
						 USE_CNT     = USE_CNT - 1,
						 CUSTOMERID  = NULL,
						 ORDERNO	    = NULL,
						 CONTRACTSEQ = NULL,
						 CUST_NO     = NULL,
						 FIRST_CUSTOMER 	= NULL,
						 FIRST_SALEDT 		= NULL,
						 FIRST_SELLER 		= NULL,
						 FIRST_PARTNER 	= NULL,
						 FIRST_SALE_AMT 	= NULL,						 						 
						 UPDT_USER   = :gs_user_id,
						 UPDTDT		 = SYSDATE						 
				WHERE  EQUIPSEQ    = :ll_equipseq;				
			ELSE					
				UPDATE EQUIPMST
				SET    STATUS 	    = :ls_status,
						 CUSTOMERID  = NULL,
						 ORDERNO	    = NULL,
						 CONTRACTSEQ = NULL,
						 CUST_NO     = NULL,
						 UPDT_USER   = :gs_user_id,
						 UPDTDT		 = SYSDATE						
				WHERE  EQUIPSEQ    = :ll_equipseq;											 
			END IF			
						
			IF SQLCA.SQLCODE <> 0 THEN		//For Programer
				f_msg_usr_err(9000, Title, "장비 원복에 실패했습니다.")
				ROLLBACK;
				RETURN -1
			ELSE
				//INSERT EQUIPLOG
				INSERT INTO EQUIPLOG
				(EQUIPSEQ,		SEQ,				LOGDATE,		LOG_STATUS,		SERIALNO,
				 CONTNO,			DACOM_MNG_NO,	MAC_ADDR,	MAC_ADDR2,		ADTYPE,
				 MAKERCD,		MODELNO,			STATUS,		VALID_STATUS,	USE_YN,
				 ADSTAT,			IDATE,			ISEQNO,		ENTSTORE,		MOVENO,
				 MV_PARTNER,	TO_PARTNER,		SN_PARTNER,	SNMOVEDT,		SALEDT,
				 RETDT,			CUSTOMERID,		CONTRACTSEQ,ORDERNO,			CUST_NO,
				 IDAMT,   	   SALE_AMT,		ITEMCOD,		SALE_FLAG,		REMARK,
				 SAP_NO,		 	NEW_YN,			USE_CNT,    CRT_USER,		CRTDT,
				 PGM_ID,			TROUBLE_CAUSE,	FIRST_CUSTOMER, FIRST_SALEDT, FIRST_SELLER,
				 FIRST_PARTNER, FIRST_SALE_AMT, CHANGE_REASON)
				SELECT EQUIPSEQ,	SEQ_EQUIPLOG.NEXTVAL,	SYSDATE, 	:ls_action, 	SERIALNO,
						 CONTNO,		DACOM_MNG_NO,				MAC_ADDR,	MAC_ADDR2,		ADTYPE,
						 MAKERCD,	MODELNO,						STATUS,		VALID_STATUS,	USE_YN,
						 ADSTAT,			IDATE,			ISEQNO,		ENTSTORE,		MOVENO,
						 MV_PARTNER,	TO_PARTNER,		SN_PARTNER,	SNMOVEDT,		SALEDT,
						 RETDT,			CUSTOMERID,		CONTRACTSEQ,ORDERNO,			CUST_NO,
						 IDAMT,   	   SALE_AMT,		ITEMCOD,		SALE_FLAG,		REMARK,			  
						 SAP_NO,		 	NEW_YN,			USE_CNT,    :gs_user_id,	SYSDATE,
						 :gs_pgm_id[gi_open_win_no],  TROUBLE_CAUSE,	FIRST_CUSTOMER, FIRST_SALEDT, FIRST_SELLER,
						 FIRST_PARTNER, FIRST_SALE_AMT, CHANGE_REASON
				FROM   EQUIPMST
				WHERE  EQUIPSEQ = :ll_equipseq;					
				
				IF SQLCA.SQLCODE <> 0 THEN		//For Programer
					f_msg_usr_err(9000, Title, "장비 원복에 실패했습니다.")
					ROLLBACK;
					RETURN -1
				ELSE							
					COMMIT;
				END IF
			END IF
		END IF
	END IF
END IF

return 0
end function

public function integer wf_action_code (ref string as_code);IF IsNull(is_status)  OR is_status = ""  THEN RETURN -1
IF IsNull(is_gubunnm) OR is_gubunnm = "" THEN RETURN -1
IF IsNull(is_work)    OR is_work = "" 	  THEN RETURN -1

CHOOSE CASE is_status
	CASE '10'			//신규신청
		IF is_work = "DELETE" THEN
			IF is_gubunnm = "전화" THEN
				as_code = "TEL800"
			ELSE
				as_code = "INT800"
			END IF
		ELSEIF is_work = "RETRY" THEN
			IF is_gubunnm = "전화" THEN
				as_code = "TEL100RTY"
			ELSE
				as_code = "INT100RTY"
			END IF
		ELSE
			IF is_gubunnm = "전화" THEN
				as_code = "TEL100"
			ELSE
				as_code = "INT100"
			END IF			
		END IF
	CASE '20'			//개통 ( 변경 - 장비변경 )
		IF is_work = "RETRY" THEN
			IF is_gubunnm = "전화" THEN
				as_code = "TEL310RTY"
			ELSE
				as_code = "INT312RTY"
			END IF
		ELSE
			IF is_gubunnm = "전화" THEN
				as_code = "TEL310"
			ELSE
				as_code = "INT312"
			END IF			
		END IF
	CASE '30'			//정지신청
		IF is_work = "RETRY" THEN
			IF is_gubunnm = "전화" THEN
				as_code = "TEL412RTY"
			ELSE
				as_code = "INT400RTY"
			END IF
		ELSE
			IF is_gubunnm = "전화" THEN
				as_code = "TEL412"
			ELSE
				as_code = "INT400"
			END IF
		END IF
	CASE '50'			//해소신청
		IF is_work = "RETRY" THEN
			IF is_gubunnm = "전화" THEN
				as_code = "TEL512RTY"
			ELSE
				as_code = "INT500RTY"
			END IF		
		ELSE
			IF is_gubunnm = "전화" THEN
				as_code = "TEL512"
			ELSE
				as_code = "INT500"
			END IF		
		END IF
	CASE '70'			//해지신청
		IF is_work = "RETRY" THEN
			IF is_gubunnm = "전화" THEN
				as_code = "TEL200RTY"
			ELSE
				as_code = "INT200RTY"
			END IF
		ELSE
			IF is_gubunnm = "전화" THEN
				as_code = "TEL200"
			ELSE
				as_code = "INT200"
			END IF
		END IF
END CHOOSE		

return 0
end function

public function integer wf_equip_clear (string data_check, string data_all, integer data_row);STRING	ls_data_check,		ls_new_check,		ls_action
LONG		ll_row,		ll_equipseq
INT		ii

dw_detail.AcceptText()

//로그 행위(action)추출 - 인증
SELECT ref_content		INTO :ls_action		FROM sysctl1t 
WHERE module = 'U3' AND ref_no = 'A108';	

ll_row = dw_detail.RowCount()

IF data_check = "I" THEN						//신규로 들어간놈 정리
	IF data_all = "A" THEN						//신규 전체 정리
		IF data_row = 0 THEN
			FOR ii = 1 TO ll_row
				ls_data_check = dw_detail.Object.data_check[ii]
				ll_equipseq	  = dw_detail.Object.equipseq[ii]
				ls_new_check  = dw_detail.Object.new_check[ii]
				
				IF ls_data_check = "I" THEN		//신규인 놈만 정리	
					IF ls_new_check = 'Y' THEN				
						UPDATE EQUIPMST
						SET    STATUS      = :is_rental900[1],
								 NEW_YN		 = 'Y',
		 						 USE_CNT     = USE_CNT - 1,
								 CUSTOMERID  = NULL,
								 ORDERNO     = NULL,
								 CONTRACTSEQ = NULL,
								 CUST_NO     = NULL,
								 FIRST_CUSTOMER 	= NULL,
								 FIRST_SALEDT 		= NULL,
								 FIRST_SELLER 		= NULL,
								 FIRST_PARTNER 	= NULL,
								 FIRST_SALE_AMT 	= NULL,						 								 
								 UPDT_USER   = :gs_user_id,
								 UPDTDT		 = SYSDATE
						WHERE  EQUIPSEQ    = :ll_equipseq;
					ELSE
						UPDATE EQUIPMST
						SET    STATUS      = :is_rental900[1],
		 						 USE_CNT     = USE_CNT - 1,
								 CUSTOMERID  = NULL,
								 ORDERNO     = NULL,
								 CONTRACTSEQ = NULL,
								 CUST_NO     = NULL,
								 UPDT_USER   = :gs_user_id,
								 UPDTDT		 = SYSDATE
						WHERE  EQUIPSEQ    = :ll_equipseq;	
					END IF						
					
					IF SQLCA.SQLCODE <> 0 THEN		//For Programer
						f_msg_usr_err(9000, Title, "장비 원복에 실패했습니다.")
						ROLLBACK;
						RETURN -1
					ELSE
						//INSERT EQUIPLOG
						INSERT INTO EQUIPLOG
						(EQUIPSEQ,		SEQ,				LOGDATE,		LOG_STATUS,		SERIALNO,
						 CONTNO,			DACOM_MNG_NO,	MAC_ADDR,	MAC_ADDR2,		ADTYPE,
						 MAKERCD,		MODELNO,			STATUS,		VALID_STATUS,	USE_YN,
						 ADSTAT,			IDATE,			ISEQNO,		ENTSTORE,		MOVENO,
						 MV_PARTNER,	TO_PARTNER,		SN_PARTNER,	SNMOVEDT,		SALEDT,
						 RETDT,			CUSTOMERID,		CONTRACTSEQ,ORDERNO,			CUST_NO,
						 IDAMT,   	   SALE_AMT,		ITEMCOD,		SALE_FLAG,		REMARK,
						 SAP_NO,		 	NEW_YN,			USE_CNT,    CRT_USER,		CRTDT,
						 PGM_ID,			TROUBLE_CAUSE,	FIRST_CUSTOMER, FIRST_SALEDT, FIRST_SELLER,
						 FIRST_PARTNER, FIRST_SALE_AMT, CHANGE_REASON)
						SELECT EQUIPSEQ,	SEQ_EQUIPLOG.NEXTVAL,	SYSDATE, 	:ls_action, 	SERIALNO,
								 CONTNO,		DACOM_MNG_NO,				MAC_ADDR,	MAC_ADDR2,		ADTYPE,
								 MAKERCD,	MODELNO,						STATUS,		VALID_STATUS,	USE_YN,
								 ADSTAT,			IDATE,			ISEQNO,		ENTSTORE,		MOVENO,
								 MV_PARTNER,	TO_PARTNER,		SN_PARTNER,	SNMOVEDT,		SALEDT,
								 RETDT,			CUSTOMERID,		CONTRACTSEQ,ORDERNO,			CUST_NO,
								 IDAMT,   	   SALE_AMT,		ITEMCOD,		SALE_FLAG,		REMARK,			  
								 SAP_NO,		 	NEW_YN,			USE_CNT,    :gs_user_id,	SYSDATE,
								 :gs_pgm_id[gi_open_win_no],  TROUBLE_CAUSE,	FIRST_CUSTOMER, FIRST_SALEDT, FIRST_SELLER,
								 FIRST_PARTNER, FIRST_SALE_AMT, CHANGE_REASON
						FROM   EQUIPMST
						WHERE  EQUIPSEQ = :ll_equipseq;					
						
						IF SQLCA.SQLCODE <> 0 THEN		//For Programer
							f_msg_usr_err(9000, Title, "장비 원복에 실패했습니다.")
							ROLLBACK;
							RETURN -1
						ELSE							
							COMMIT;
						END IF
					END IF
				END IF
			NEXT
		ELSE
			FOR ii = data_row TO ll_row
				ls_data_check = dw_detail.Object.data_check[ii]
				ll_equipseq	  = dw_detail.Object.equipseq[ii]
				ls_new_check  = dw_detail.Object.new_check[ii]
				
				IF ls_data_check = "I" THEN		//신규인 놈만 정리	
					IF ls_new_check = 'Y' THEN				
						UPDATE EQUIPMST
						SET    STATUS      = :is_rental900[1],
								 NEW_YN		 = 'Y',
								 USE_CNT     = USE_CNT - 1,
								 CUSTOMERID  = NULL,
								 ORDERNO     = NULL,
								 CONTRACTSEQ = NULL,
								 CUST_NO     = NULL,
								 FIRST_CUSTOMER 	= NULL,
								 FIRST_SALEDT 		= NULL,
								 FIRST_SELLER 		= NULL,
								 FIRST_PARTNER 	= NULL,
								 FIRST_SALE_AMT 	= NULL,						 								 
								 UPDT_USER   = :gs_user_id,
								 UPDTDT		 = SYSDATE
						WHERE  EQUIPSEQ    = :ll_equipseq;
					ELSE
						UPDATE EQUIPMST
						SET    STATUS      = :is_rental900[1],
								 USE_CNT     = USE_CNT - 1,
								 CUSTOMERID  = NULL,
								 ORDERNO     = NULL,
								 CONTRACTSEQ = NULL,
								 CUST_NO     = NULL,
								 UPDT_USER   = :gs_user_id,
								 UPDTDT		 = SYSDATE
						WHERE  EQUIPSEQ    = :ll_equipseq;	
					END IF											
					
					IF SQLCA.SQLCODE <> 0 THEN		//For Programer
						f_msg_usr_err(9000, Title, "장비 원복에 실패했습니다.")
						ROLLBACK;
						RETURN -1
					ELSE
						//INSERT EQUIPLOG
						INSERT INTO EQUIPLOG
						(EQUIPSEQ,		SEQ,				LOGDATE,		LOG_STATUS,		SERIALNO,
						 CONTNO,			DACOM_MNG_NO,	MAC_ADDR,	MAC_ADDR2,		ADTYPE,
						 MAKERCD,		MODELNO,			STATUS,		VALID_STATUS,	USE_YN,
						 ADSTAT,			IDATE,			ISEQNO,		ENTSTORE,		MOVENO,
						 MV_PARTNER,	TO_PARTNER,		SN_PARTNER,	SNMOVEDT,		SALEDT,
						 RETDT,			CUSTOMERID,		CONTRACTSEQ,ORDERNO,			CUST_NO,
						 IDAMT,   	   SALE_AMT,		ITEMCOD,		SALE_FLAG,		REMARK,
						 SAP_NO,		 	NEW_YN,			USE_CNT,    CRT_USER,		CRTDT,
						 PGM_ID,			TROUBLE_CAUSE,	FIRST_CUSTOMER, FIRST_SALEDT, FIRST_SELLER,
						 FIRST_PARTNER, FIRST_SALE_AMT, CHANGE_REASON)
						SELECT EQUIPSEQ,	SEQ_EQUIPLOG.NEXTVAL,	SYSDATE, 	:ls_action, 	SERIALNO,
								 CONTNO,		DACOM_MNG_NO,				MAC_ADDR,	MAC_ADDR2,		ADTYPE,
								 MAKERCD,	MODELNO,						STATUS,		VALID_STATUS,	USE_YN,
								 ADSTAT,			IDATE,			ISEQNO,		ENTSTORE,		MOVENO,
								 MV_PARTNER,	TO_PARTNER,		SN_PARTNER,	SNMOVEDT,		SALEDT,

								 RETDT,			CUSTOMERID,		CONTRACTSEQ,ORDERNO,			CUST_NO,
								 IDAMT,   	   SALE_AMT,		ITEMCOD,		SALE_FLAG,		REMARK,			  
								 SAP_NO,		 	NEW_YN,			USE_CNT,    :gs_user_id,	SYSDATE,
								 :gs_pgm_id[gi_open_win_no],  TROUBLE_CAUSE,	FIRST_CUSTOMER, FIRST_SALEDT, FIRST_SELLER,
								 FIRST_PARTNER, FIRST_SALE_AMT, CHANGE_REASON
						FROM   EQUIPMST
						WHERE  EQUIPSEQ = :ll_equipseq;					
						
						IF SQLCA.SQLCODE <> 0 THEN		//For Programer
							f_msg_usr_err(9000, Title, "장비 원복에 실패했습니다.")
							ROLLBACK;
							RETURN -1
						ELSE							
							COMMIT;
						END IF
					END IF														
				END IF
			NEXT			
		END IF
	ELSE												//신규 일부 정리 ( row 받음 )
		ls_data_check = dw_detail.Object.data_check[data_row]
		ll_equipseq	  = dw_detail.Object.equipseq[data_row]	
		ls_new_check  = dw_detail.Object.new_check[data_row]		
		
		IF ls_data_check = "I" THEN
			IF ls_new_check = "Y" THEN
				UPDATE EQUIPMST
				SET    STATUS      = :is_rental900[1],
						 NEW_YN		 = 'Y',
						 USE_CNT     = USE_CNT - 1,
						 CUSTOMERID  = NULL,
						 ORDERNO     = NULL,
						 CONTRACTSEQ = NULL,
						 CUST_NO     = NULL,
						 FIRST_CUSTOMER 	= NULL,
						 FIRST_SALEDT 		= NULL,
						 FIRST_SELLER 		= NULL,
						 FIRST_PARTNER 	= NULL,
						 FIRST_SALE_AMT 	= NULL,						 						 
						 UPDT_USER   = :gs_user_id,
						 UPDTDT		 = SYSDATE
				WHERE  EQUIPSEQ    = :ll_equipseq;
			ELSE
				UPDATE EQUIPMST
				SET    STATUS      = :is_rental900[1],
						 USE_CNT     = USE_CNT - 1,
						 CUSTOMERID  = NULL,
						 ORDERNO     = NULL,
						 CONTRACTSEQ = NULL,
						 CUST_NO     = NULL,
						 UPDT_USER   = :gs_user_id,
						 UPDTDT		 = SYSDATE
				WHERE  EQUIPSEQ    = :ll_equipseq;	
			END IF
			
			IF SQLCA.SQLCODE <> 0 THEN		//For Programer
				f_msg_usr_err(9000, Title, "장비 원복에 실패했습니다.")
				ROLLBACK;
				RETURN -1
			ELSE
				//INSERT EQUIPLOG
				INSERT INTO EQUIPLOG
				(EQUIPSEQ,		SEQ,				LOGDATE,		LOG_STATUS,		SERIALNO,
				 CONTNO,			DACOM_MNG_NO,	MAC_ADDR,	MAC_ADDR2,		ADTYPE,
				 MAKERCD,		MODELNO,			STATUS,		VALID_STATUS,	USE_YN,
				 ADSTAT,			IDATE,			ISEQNO,		ENTSTORE,		MOVENO,
				 MV_PARTNER,	TO_PARTNER,		SN_PARTNER,	SNMOVEDT,		SALEDT,
				 RETDT,			CUSTOMERID,		CONTRACTSEQ,ORDERNO,			CUST_NO,
				 IDAMT,   	   SALE_AMT,		ITEMCOD,		SALE_FLAG,		REMARK,
				 SAP_NO,		 	NEW_YN,			USE_CNT,    CRT_USER,		CRTDT,
				 PGM_ID,			TROUBLE_CAUSE,	FIRST_CUSTOMER, FIRST_SALEDT, FIRST_SELLER,
				 FIRST_PARTNER, FIRST_SALE_AMT, CHANGE_REASON)
				SELECT EQUIPSEQ,	SEQ_EQUIPLOG.NEXTVAL,	SYSDATE, 	:ls_action, 	SERIALNO,
						 CONTNO,		DACOM_MNG_NO,				MAC_ADDR,	MAC_ADDR2,		ADTYPE,
						 MAKERCD,	MODELNO,						STATUS,		VALID_STATUS,	USE_YN,
						 ADSTAT,			IDATE,			ISEQNO,		ENTSTORE,		MOVENO,
						 MV_PARTNER,	TO_PARTNER,		SN_PARTNER,	SNMOVEDT,		SALEDT,
						 RETDT,			CUSTOMERID,		CONTRACTSEQ,ORDERNO,			CUST_NO,
						 IDAMT,   	   SALE_AMT,		ITEMCOD,		SALE_FLAG,		REMARK,			  
						 SAP_NO,		 	NEW_YN,			USE_CNT,    :gs_user_id,	SYSDATE,
						 :gs_pgm_id[gi_open_win_no],  TROUBLE_CAUSE,	FIRST_CUSTOMER, FIRST_SALEDT, FIRST_SELLER,
						 FIRST_PARTNER, FIRST_SALE_AMT, CHANGE_REASON
				FROM   EQUIPMST
				WHERE  EQUIPSEQ = :ll_equipseq;					
				
				IF SQLCA.SQLCODE <> 0 THEN		//For Programer
					f_msg_usr_err(9000, Title, "장비 원복에 실패했습니다.")
					ROLLBACK;
					RETURN -1
				ELSE							
					COMMIT;
				END IF				
			END IF	
		END IF
	END IF
END IF		

return 0
end function

on ubs_w_pop_equipvalid_nonvalid.create
int iCurrent
call super::create
this.dw_master=create dw_master
this.p_save=create p_save
this.dw_split=create dw_split
this.dw_detail=create dw_detail
this.cb_next=create cb_next
this.cb_pre=create cb_pre
this.p_reset=create p_reset
this.cb_1=create cb_1
this.st_1=create st_1
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_master
this.Control[iCurrent+2]=this.p_save
this.Control[iCurrent+3]=this.dw_split
this.Control[iCurrent+4]=this.dw_detail
this.Control[iCurrent+5]=this.cb_next
this.Control[iCurrent+6]=this.cb_pre
this.Control[iCurrent+7]=this.p_reset
this.Control[iCurrent+8]=this.cb_1
this.Control[iCurrent+9]=this.st_1
this.Control[iCurrent+10]=this.gb_1
end on

on ubs_w_pop_equipvalid_nonvalid.destroy
call super::destroy
destroy(this.dw_master)
destroy(this.p_save)
destroy(this.dw_split)
destroy(this.dw_detail)
destroy(this.cb_next)
destroy(this.cb_pre)
destroy(this.p_reset)
destroy(this.cb_1)
destroy(this.st_1)
destroy(this.gb_1)
end on

event open;call super::open;/*=================================================================================================
 Desciption : 장비인증 팝업							                                     
 Name       : ubs_w_pop_equipvalid	                    
 contents   : 장비인증을 받는 팝업메뉴이다.				  
 call Window: ubs_w_pop_equipvalid	                     
 작성일자   : 2009.05.07                                 
 작 성 자   : 최재혁 대리                                
 수정일자   :                                            
 수 정 자   :                                            
=================================================================================================*/
DataWindowChild 	ldc_modelno
Long 					li_exist,			ll_row,				ll_cnt,			ll_cnt2,		      &
						ll_orderno
String 				ls_filter,			ls_sql,				old_sql,			new_sql,		      &
						ls_ref_desc,		ls_temp,				ls_customerid, ls_contractseq,	&
						ls_siid,				ls_status

iu_cust_db_app = Create u_cust_db_app

// 스케쥴관리 화면에서 인증 버튼 클릭시 넘어오는 값

dw_hlp.InsertRow(0)

is_orderno 	 = iu_cust_help.is_data[2]
is_partner 	 = iu_cust_help.is_data[3]
is_userid  	 = iu_cust_help.is_data[4]
is_priceplan = iu_cust_help.is_data[5]
is_svccod 	 = iu_cust_help.is_data[6]
is_vocm 		 = iu_cust_help.is_data[7]
is_status	 = iu_cust_help.is_data[8]
is_gubunnm	 = iu_cust_help.is_data[9]
is_worktype  = iu_cust_help.is_data2[1]
is_troubleno = iu_cust_help.is_data2[2]

IF IsNull(is_orderno) OR is_orderno = "" THEN
	is_orderno = is_troubleno
END IF

//IF is_vocm = 'VOCM' AND is_gubunnm = '전화'	THEN   //VOCM 일경우 인터넷 장비를 찾기 위하여!!!
//	SELECT TO_CHAR(RELATED_ORDERNO)	INTO :is_ref_orderno
//	FROM   SVCORDER
//	WHERE  ORDERNO  = :is_orderno;
//
//	IF IsNull(is_ref_orderno) THEN is_ref_orderno = ''
//ELSE
	is_ref_orderno = ''
//END IF

This.Title =  iu_cust_help.is_pgm_name 

li_exist 	= dw_hlp.GetChild("modelno", ldc_modelno)		//DDDW 구함
If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : 장비종류")

ldc_modelno.SetTransObject(SQLCA)

old_sql = "SELECT  EQUIPMODEL.MODELNO, EQUIPMODEL.MODELNM " + &
          "FROM    EQUIPMODEL, PRICEPLAN_EQUIP, SVCORDER " +&
			 "WHERE   EQUIPMODEL.EQUIPTYPE = PRICEPLAN_EQUIP.ADTYPE " +&
			 "AND     PRICEPLAN_EQUIP.PRICEPLAN = SVCORDER.PRICEPLAN ";

//IF is_vocm = 'VOCM' AND is_gubunnm = '전화'	THEN   //VOCM 일경우 인터넷 장비를 찾기 위하여!!!
//	new_sql = old_sql + " AND SVCORDER.ORDERNO = TO_NUMBER('" + is_ref_orderno + "') "
//ELSE	
	IF is_worktype <> '100' AND is_worktype <> '400'  THEN				//신규, auto가 아닐경우
		SELECT CUSTOMERID, CONTRACTSEQ INTO :ls_customerid, :ls_contractseq 
		FROM   CUSTOMER_TROUBLE 
		WHERE  TROUBLENO = TO_NUMBER(:is_troubleno);
		
		is_contractseq = ls_contractseq
		is_customerid  = ls_customerid
		
//		SELECT EX_SIID INTO :ll_orderno
//		FROM   SIID
//		WHERE  CONTRACTSEQ = :ls_contractseq;
     
	    SELECT ORDERNO INTO :ll_orderno
		 FROM SVCORDER 
		 WHERE REF_CONTRACTSEQ = :ls_contractseq;

		
		SELECT STATUS INTO :ls_status
		FROM   SVCORDER
		WHERE  ORDERNO = :ll_orderno;
		
		
		IF IsNull(is_troubleno) = FALSE OR is_troubleno <> "" THEN
			is_orderno = STRING(ll_orderno)
			is_status  = ls_status
			
			new_sql = old_sql + " AND SVCORDER.CUSTOMERID = '" + ls_customerid + "' " +&
									  " AND SVCORDER.REF_CONTRACTSEQ = '" + ls_contractseq + "' "
		ELSE
			new_sql = old_sql + " AND SVCORDER.ORDERNO = TO_NUMBER('" + is_orderno + "') "		
		END IF
	ELSE
		SELECT CUSTOMERID INTO :is_customerid
		FROM   SVCORDER
		WHERE  ORDERNO = :is_orderno;
		
		new_sql = old_sql + " AND SVCORDER.ORDERNO = TO_NUMBER('" + is_orderno + "') "
	END IF
//END IF

new_sql = new_sql + " GROUP BY EQUIPMODEL.MODELNO, EQUIPMODEL.MODELNM ORDER BY EQUIPMODEL.MODELNM ASC "

//messagebox("query", new_sql)

ldc_modelno.SetSQLSelect(new_sql)
li_exist =ldc_modelno.Retrieve()
	
If li_exist < 0 Then 				
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return 1  	
End If  
//shop 세팅!
dw_hlp.Object.shop[1] = is_partner

//임대가능 장비상태 코드
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("U0", "E700", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", is_rental700[])

//임대상태 코드
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("U0", "E800", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", is_rental800[])



//임대가능상태 코드
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("U0", "E900", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", is_rental900[])

//고장상태 코드(교체)
ls_ref_desc = ""
is_bad_status = fs_get_control("U0", "S800", ls_ref_desc)

//wifi adtype 코드
ls_ref_desc = ""
ls_temp = ""
ls_temp = fs_get_control("U0", "S400", ls_ref_desc)

If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";", is_wifi[])

is_old_sql = dw_master.GetSQLSelect()

IF TRIGGER EVENT ue_retrieve_right() < 0 THEN
	f_msg_usr_err(2100, Title, "Retrieve() Right")
	RETURN -1		
END IF

ll_row = dw_detail.RowCount()

IF ll_row > 0 THEN
	IF is_worktype <> '100' AND is_worktype <> '400'  THEN				//신규, auto가 아닐경우
		SELECT CUSTOMERID, CONTRACTSEQ INTO :ls_customerid, :ls_contractseq 
		FROM   CUSTOMER_TROUBLE 
		WHERE  TROUBLENO = TO_NUMBER(:is_troubleno);
		
//		SELECT SIID INTO :ls_siid
//		FROM   SIID
//		WHERE  CONTRACTSEQ = :ls_contractseq;
//	ELSE			
////		SELECT SIID INTO :ls_siid
////		FROM   SIID
////		WHERE  ORDERNO = :is_orderno;
//		SELECT SIID INTO :ls_siid
//		FROM   SIID
//		WHERE  EX_SIID = :is_orderno;
	END IF
	
//	SELECT COUNT(*) INTO :ll_cnt
//	FROM   BC_REG_SSW
//	WHERE  SUBSNO = :ls_siid
//	AND  	 FLAG = '0';
//	
//	SELECT COUNT(*) INTO :ll_cnt2
//	FROM   BC_AUTH
//	WHERE  SUBSNO = :ls_siid	
//	AND    FLAG = '0';
//	
//	IF ll_cnt > 0 OR ll_cnt2 > 0 THEN
//		f_msg_usr_err(9000, Title, "잠시만 기다려 주세요! 기존 인증이 진행중입니다.")
//		Triggerevent("ue_close")
//		RETURN -1
//	END IF
ELSE
	//조회 내역 없으면 버튼 막는다.
	cb_1.Enabled = False
END IF

//messagebox("worktype", is_worktype) 

IF is_worktype = '400' THEN   //AUTO 재인증만 허용!
   cb_next.Enabled = False
	cb_pre.Enabled = False
	p_save.Triggerevent("ue_disable")
END IF

is_save_check = 'N'

//수정된 내용이 없도록 하기 위해서 강제 세팅!
//dw_hlp.SetItemStatus(1, 0, Primary!, NotModified!)

end event

event ue_close();//iu_cust_help.ib_data[1] = TRUE
//iu_cust_help.is_data[1] = is_amt_check    //수납 했는지 확인 후 값 넘김

Destroy iu_cust_db_app

Close( This )
end event

event close;

LONG		ll_equipseq,ll_cust_no
STRING	ls_data_check , ls_spec_item1
INT		ii

iu_cust_help.ib_data[1] = TRUE
iu_cust_help.is_data[1] = is_amt_check    //수납 했는지 확인 후 값 넘김

dw_detail.AcceptText()

IF is_save_check = 'N' THEN 
	FOR ii = 1 TO dw_detail.RowCount()
		
				ls_data_check = dw_detail.Object.data_check[ii]
					
				ls_spec_item1 = dw_detail.Object.spec_item1[ii] //2013.07.23 김선주 추가 
																			  //이윤주 대리 요청으로,자급폰의 경우에는 해당 로직을 타지 않도록 하기 위함.
				ll_equipseq   = dw_detail.Object.equipseq[ii]
				
			 //할당고객이 없으면 초기화 한다.
			  SELECT customerid
				  INTO :ll_cust_no
				  FROM EQUIPMST
				 WHERE EQUIPSEQ = :ll_equipseq;
				 
				IF IsNull( ll_cust_no ) = True Or ll_cust_no = 0 Then 
					IF IsNull(ls_spec_item1) = True or  ls_spec_item1 <> 'Y' Then  
						IF ls_data_check = 'R' THEN //자급폰이 아닌것 
							UPDATE EQUIPMST
							SET    STATUS      = :is_rental900[1], //200(예비) 
									 CUSTOMERID  = NULL,
									 ORDERNO     = NULL,
									 CONTRACTSEQ = NULL,
									 CUST_NO     = NULL
							WHERE  EQUIPSEQ    = :ll_equipseq;
							
							IF SQLCA.SQLCODE <> 0 THEN		//For Programer
								f_msg_usr_err(9000, Title, "장비 원복에 실패했습니다.")
								ROLLBACK;
								RETURN -1
							ELSE
								COMMIT;
							END IF	
						END IF;	
					END IF	  
				END IF	
	
	NEXT
END IF

return 0

			
end event

event closequery;call super::closequery;Int li_rc

dw_detail.AcceptText()

If (dw_detail.ModifiedCount() > 0) Or (dw_detail.DeletedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return 1 //Process Cancel
End If
end event

type p_1 from w_a_hlp`p_1 within ubs_w_pop_equipvalid_nonvalid
boolean visible = false
integer x = 2258
integer y = 1640
boolean enabled = false
end type

type dw_cond from w_a_hlp`dw_cond within ubs_w_pop_equipvalid_nonvalid
boolean visible = false
boolean enabled = false
end type

type p_ok from w_a_hlp`p_ok within ubs_w_pop_equipvalid_nonvalid
boolean visible = false
integer x = 2574
integer y = 1640
boolean enabled = false
end type

type p_close from w_a_hlp`p_close within ubs_w_pop_equipvalid_nonvalid
integer x = 347
integer y = 1176
end type

type gb_cond from w_a_hlp`gb_cond within ubs_w_pop_equipvalid_nonvalid
boolean visible = false
boolean enabled = false
end type

type dw_hlp from w_a_hlp`dw_hlp within ubs_w_pop_equipvalid_nonvalid
integer x = 41
integer y = 36
integer width = 3026
integer height = 172
string dataobject = "ubs_dw_pop_equipvalid_cond"
boolean vscrollbar = false
boolean border = false
boolean hsplitscroll = false
boolean livescroll = false
end type

event dw_hlp::itemchanged;call super::itemchanged;IF dwo.name = "modelno" OR dwo.name = "searchno" THEN
	IF PARENT.TRIGGER EVENT ue_retrieve_left() < 0 THEN
		f_msg_usr_err(2100, Title, "Retrieve() Left")
		RETURN -1
	END IF
	
//	IF PARENT.TRIGGER EVENT ue_retrieve_right() < 0 THEN
//		f_msg_usr_err(2100, Title, "Retrieve() Right")
//		RETURN -1		
//	END IF		
END IF

RETURN 0
end event

event dw_hlp::clicked;//
end event

event dw_hlp::doubleclicked;//
end event

event dw_hlp::retrieveend;//
end event

event dw_hlp::ue_init();//
end event

event dw_hlp::losefocus;STRING	ls_searchno

dw_hlp.AcceptText()

ls_searchno = THIS.object.searchno[1]

IF IsNull(ls_searchno) OR ls_searchno = "" THEN RETURN 0

IF PARENT.TRIGGER EVENT ue_retrieve_left() < 0 THEN
	f_msg_usr_err(2100, Title, "Retrieve() Left")
	RETURN -1
END IF

//IF PARENT.TRIGGER EVENT ue_retrieve_right() < 0 THEN
//	f_msg_usr_err(2100, Title, "Retrieve() Right")
//	RETURN -1		
//END IF		

RETURN 0
end event

type dw_master from datawindow within ubs_w_pop_equipvalid_nonvalid
integer x = 18
integer y = 256
integer width = 1266
integer height = 868
integer taborder = 20
boolean bringtotop = true
string title = "none"
string dataobject = "ubs_dw_pop_equipvalid_mas"
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

event constructor;SetTransObject(SQLCA)
end event

event clicked;If row = 0 then Return

If IsSelected( row ) then
	SelectRow( row ,FALSE)
Else
   SelectRow(0, FALSE )
	SelectRow( row , TRUE )
End If
end event

type p_save from u_p_save within ubs_w_pop_equipvalid_nonvalid
integer x = 18
integer y = 1176
integer height = 100
boolean bringtotop = true
boolean originalsize = false
end type

event clicked;Integer li_rc
Constant Int LI_ERROR = -1

// 필수 입력값 체크 
//PARENT.TRIGGER EVENT ue_inputvalidcheck(li_rc)

//IF li_rc <> 0 THEN
//	RETURN -1
//END IF

//PARENT.TRIGGER EVENT ue_processvalidcheck(li_rc)

//IF li_rc <> 0 THEN
//	RETURN -1
//END IF

PARENT.TRIGGER EVENT ue_process(li_rc)

IF li_rc <> 0 THEN
	//ROLLBACK와 동일한 기능
//	iu_cust_db_app.is_caller = "ROLLBACK"
//	iu_cust_db_app.is_title = PARENT.Title

//	iu_cust_db_app.uf_prc_db()
	
//	IF iu_cust_db_app.ii_rc = -1 THEN
//		dw_master.SetFocus()
//		RETURN LI_ERROR
//	END IF
	ROLLBACK;
	f_msg_info(3010, PARENT.Title, "Save")	
ELSEIF li_rc = 0 THEN
		
	//COMMIT와 동일한 기능
//	iu_cust_db_app.is_caller = "COMMIT"
//	iu_cust_db_app.is_title = PARENT.Title

//	iu_cust_db_app.uf_prc_db()

//	IF iu_cust_db_app.ii_rc = -1 THEN
//		dw_master.SetFocus()
//		RETURN LI_ERROR
//	END IF
	COMMIT;
	f_msg_info(3000, PARENT.Title, "Save")	
END IF

cb_next.Enabled = False
cb_pre.Enabled = False

//수정된 내용이 없도록 하기 위해서 강제 세팅!
//dw_master.SetItemStatus(1, 0, Primary!, NotModified!)
//dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)

PARENT.TRIGGEREVENT('ue_close')
end event

type dw_split from datawindow within ubs_w_pop_equipvalid_nonvalid
boolean visible = false
integer x = 1838
integer y = 1168
integer width = 969
integer height = 148
integer taborder = 20
boolean bringtotop = true
string title = "none"
string dataobject = "b5d_reg_mtr_inp_split_sams"
boolean livescroll = true
end type

event constructor;SetTransObject(SQLCA)
end event

type dw_detail from datawindow within ubs_w_pop_equipvalid_nonvalid
integer x = 1458
integer y = 292
integer width = 1627
integer height = 868
integer taborder = 30
boolean bringtotop = true
string title = "none"
string dataobject = "ubs_dw_pop_equipvalid_det"
boolean hscrollbar = true
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

event constructor;SetTransObject(SQLCA)
end event

event clicked;If row = 0 then Return

If IsSelected( row ) then
	SelectRow( row ,FALSE)
Else
   SelectRow(0, FALSE )
	SelectRow( row , TRUE )
End If
end event

event retrieveend;LONG		ll_equipseq,		ll_cust_no

ii_equipselect = rowcount

IF rowcount > 0 THEN
	ll_equipseq = THIS.Object.equipseq[1]
	
	SELECT CUST_NO INTO :ll_cust_no
	FROM   EQUIPMST
	WHERE  EQUIPSEQ = :ll_equipseq;
	
	IF IsNull(ll_cust_no) THEN ll_cust_no = 0
	
	IF ll_cust_no = 0 THEN
		cb_1.Enabled = FALSE
	ELSE
		cb_1.Enabled = TRUE
	END IF
ELSE
	cb_1.Enabled = FALSE
END IF	

return 0
end event

type cb_next from commandbutton within ubs_w_pop_equipvalid_nonvalid
integer x = 1321
integer y = 512
integer width = 114
integer height = 108
integer taborder = 30
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = roman!
string facename = "바탕체"
string text = ">"
end type

event clicked;STRING	ls_equip,		ls_adtype,			ls_data_check,	ls_new_yn,		ls_new_check,	&
			ls_action
LONG		ll_row,			ll_equipseq,		ll_row_det,		ll_new_row,		ll_ret_cnt,	&
			ll_use_cnt
INT		ii

ll_row = dw_master.GetSelectedRow(0)

IF ll_row <= 0 THEN
	f_msg_usr_err(9000, Title, "임대가능장비중 선택된 행이 없습니다.")
	RETURN -1
END IF

ls_equip 	= dw_master.Object.rental_equip[ll_row]
ll_equipseq = dw_master.Object.equipseq[ll_row]
ls_new_check= dw_master.Object.new_check[ll_row]

SELECT ADTYPE, NVL(NEW_YN, 'N'), NVL(USE_CNT, 0)
INTO   :ls_adtype, :ls_new_yn, :ll_use_cnt
FROM   EQUIPMST
WHERE  EQUIPSEQ = :ll_equipseq;

IF ii_equipselect > 1 THEN 
	IF ls_adtype = is_wifi[1] OR  ls_adtype = is_wifi[2] THEN
		IF ii_equipselect > 2 THEN
			f_msg_usr_err(9000, Title, "선택가능한 장비수를 초과했습니다.")
			RETURN -1
		END IF
	ELSE
		f_msg_usr_err(9000, Title, "선택가능한 장비수를 초과했습니다.")
		RETURN -1
	END IF
END IF

ll_row_det = dw_detail.RowCount()

//로그 행위(action)추출 - 인증
SELECT ref_content		INTO :ls_action		FROM sysctl1t 
WHERE module = 'U3' AND ref_no = 'A108';	


//실사용
FOR ii = 1 TO ll_row_det
	ls_data_check   = dw_detail.Object.data_check[ii]
		
	IF ls_data_check = "R" OR ls_data_check = "D" THEN
		ll_ret_cnt += 1
	END IF
NEXT


ll_new_row = ll_row_det + 1
dw_detail.Insertrow(ll_new_row)

dw_detail.Object.rental_equip[ll_new_row] = ls_equip
dw_detail.Object.equipseq[ll_new_row]		= ll_equipseq
dw_detail.Object.data_check[ll_new_row]	= "I" 				//추가 라고 표시
dw_detail.Object.new_check[ll_new_row]	= ls_new_check		//신규 장비 구분...

IF is_worktype = '100' THEN
	IF ls_new_check = 'N' THEN		
		UPDATE EQUIPMST
		SET    STATUS 	   = :is_rental800[1],
				 CUSTOMERID = :is_customerid,
				 ORDERNO	   = TO_NUMBER(:is_orderno),
				 NEW_YN		= 'N',					 
				 USE_CNT    = NVL(USE_CNT, 0) + 1,
				 UPDT_USER  = :gs_user_id,
				 UPDTDT		= SYSDATE
		WHERE  EQUIPSEQ   = :ll_equipseq;
	ELSE		//신규장비...
		UPDATE EQUIPMST
		SET    STATUS 	   = :is_rental800[1],
				 CUSTOMERID = :is_customerid,
				 ORDERNO	   = TO_NUMBER(:is_orderno),
				 NEW_YN		= 'N',
				 USE_CNT    = NVL(USE_CNT, 0) + 1,
				 FIRST_CUSTOMER = :is_customerid,
				 FIRST_SALEDT   = SYSDATE,
				 FIRST_SELLER   = :gs_user_id,
				 FIRST_PARTNER  = :gs_shopid,
				 FIRST_SALE_AMT = NVL(SALE_AMT, 0),
				 UPDT_USER  = :gs_user_id,
				 UPDTDT		= SYSDATE					 
		WHERE  EQUIPSEQ   = :ll_equipseq;
	END IF			

	IF SQLCA.SQLCODE < 0 THEN		//For Programer
		F_MSG_INFO(3010, Title, SQLCA.SQLERRTEXT + '~r~n ' + 'EQUIPMST UPDATE ERROR!')
		ROLLBACK;
		RETURN -1			
	END IF
ELSEIF is_worktype = '200' THEN	
	IF ls_new_check = 'N' THEN				
		UPDATE EQUIPMST
		SET    STATUS		 = :is_rental800[1],
				 CUSTOMERID  = :is_customerid,
				 ORDERNO	    = TO_NUMBER(:is_orderno),
				 CONTRACTSEQ = TO_NUMBER(:is_contractseq),
				 NEW_YN		 = 'N',					 
				 USE_CNT     = NVL(USE_CNT, 0) + 1,
				 UPDT_USER   = :gs_user_id,
				 UPDTDT		 = SYSDATE					 
		WHERE  EQUIPSEQ    = :ll_equipseq;
	ELSE
		UPDATE EQUIPMST
		SET    STATUS 	   = :is_rental800[1],
				 CUSTOMERID = :is_customerid,
				 ORDERNO	   = TO_NUMBER(:is_orderno),
				 NEW_YN		= 'N',
				 USE_CNT    = NVL(USE_CNT, 0) + 1,
				 FIRST_CUSTOMER = :is_customerid,
				 FIRST_SALEDT   = SYSDATE,
				 FIRST_SELLER   = :gs_user_id,
				 FIRST_PARTNER  = :gs_shopid,
				 FIRST_SALE_AMT = NVL(SALE_AMT, 0),
				 UPDT_USER  = :gs_user_id,
				 UPDTDT		= SYSDATE					 
		WHERE  EQUIPSEQ   = :ll_equipseq;
	END IF				
	
	IF SQLCA.SQLCODE < 0 THEN		//For Programer
		F_MSG_INFO(3010, Title, SQLCA.SQLERRTEXT + '~r~n ' + 'EQUIPMST UPDATE ERROR!')
		ROLLBACK;
		RETURN -1			
	END IF		
END IF

//INSERT EQUIPLOG
INSERT INTO EQUIPLOG
(EQUIPSEQ,		SEQ,				LOGDATE,		LOG_STATUS,		SERIALNO,
 CONTNO,			DACOM_MNG_NO,	MAC_ADDR,	MAC_ADDR2,		ADTYPE,
 MAKERCD,		MODELNO,			STATUS,		VALID_STATUS,	USE_YN,
 ADSTAT,			IDATE,			ISEQNO,		ENTSTORE,		MOVENO,
 MV_PARTNER,	TO_PARTNER,		SN_PARTNER,	SNMOVEDT,		SALEDT,
 RETDT,			CUSTOMERID,		CONTRACTSEQ,ORDERNO,			CUST_NO,
 IDAMT,   	   SALE_AMT,		ITEMCOD,		SALE_FLAG,		REMARK,
 SAP_NO,		 	NEW_YN,			USE_CNT,    CRT_USER,		CRTDT,
 PGM_ID,			TROUBLE_CAUSE,	FIRST_CUSTOMER, FIRST_SALEDT, FIRST_SELLER,
 FIRST_PARTNER, FIRST_SALE_AMT, CHANGE_REASON)
SELECT EQUIPSEQ,	SEQ_EQUIPLOG.NEXTVAL,	SYSDATE, 	:ls_action, 	SERIALNO,
		 CONTNO,		DACOM_MNG_NO,				MAC_ADDR,	MAC_ADDR2,		ADTYPE,
		 MAKERCD,	MODELNO,						STATUS,		VALID_STATUS,	USE_YN,
		 ADSTAT,			IDATE,			ISEQNO,		ENTSTORE,		MOVENO,
		 MV_PARTNER,	TO_PARTNER,		SN_PARTNER,	SNMOVEDT,		SALEDT,
		 RETDT,			CUSTOMERID,		CONTRACTSEQ,ORDERNO,			CUST_NO,
		 IDAMT,   	   SALE_AMT,		ITEMCOD,		SALE_FLAG,		REMARK,			  
		 SAP_NO,		 	NEW_YN,			USE_CNT,    :gs_user_id,	SYSDATE,
		 :gs_pgm_id[gi_open_win_no],  TROUBLE_CAUSE,	FIRST_CUSTOMER, FIRST_SALEDT, FIRST_SELLER,
		 FIRST_PARTNER, FIRST_SALE_AMT, CHANGE_REASON
FROM   EQUIPMST
WHERE  EQUIPSEQ = :ll_equipseq;					

IF SQLCA.SQLCODE < 0 THEN		//For Programer
	F_MSG_INFO(3010, Title, SQLCA.SQLERRTEXT + '~r~n ' + 'EQUIPLOG INSERT ERROR!')
	ROLLBACK;
	RETURN -1			
END IF	
	

COMMIT;

ii_equipselect = ii_equipselect + 1

F_MSG_INFO(3000, Title, 'SAVE')

PARENT.TRIGGER EVENT ue_retrieve_left()

RETURN 0
	

end event

type cb_pre from commandbutton within ubs_w_pop_equipvalid_nonvalid
integer x = 1321
integer y = 768
integer width = 114
integer height = 108
integer taborder = 40
boolean bringtotop = true
integer textsize = -10
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = roman!
string facename = "바탕체"
string text = "<"
end type

event clicked;
STRING	ls_equip,		ls_data_check,		ls_new_check,	ls_action, ls_spec_item1
STRING   ls_bef_orderno, ls_bef_customerid , ls_cust_no
LONG		ll_row,			ll_equipseq,		ll_row_mas,		ll_new_row ,ll_bef_contractseq

dw_detail.Accepttext()

ll_row = dw_detail.GetSelectedRow(0)

IF ll_row <= 0 THEN
	f_msg_usr_err(210, Title, "임대장비중 선택된 행이 없습니다.")
	RETURN -1
END IF

ls_equip 	  = dw_detail.Object.rental_equip[ll_row]
ll_equipseq   = dw_detail.Object.equipseq[ll_row]
ls_data_check = dw_detail.Object.data_check[ll_row]
ls_new_check  = dw_detail.Object.new_check[ll_row]
ls_spec_item1  = dw_detail.Object.spec_item1[ll_row] 




// 구분 필드의 내용을 체크, "R"은 예전에 썼던 값인지 지금은 Null
IF ls_data_check = "R" or ls_data_check = "I"THEN

	dw_detail.Object.data_check[ll_row] = "D"     //삭제

End IF

//로그 행위(action)추출 - 인증 : 값 = 900
SELECT ref_content		INTO :ls_action		FROM sysctl1t 
WHERE module = 'U3' AND ref_no = 'A108';	

IF is_worktype = '100' THEN    //장애 (즉 변경건 아니면)

		IF ls_data_check = 'D' or dw_detail.Object.data_check[ll_row] = 'D' THEN
	
			UPDATE EQUIPMST
			SET    STATUS 	    		= :is_rental900[1], // 200 (예비상태)
					 NEW_YN		 		= decode(:ls_new_check,'Y','Y','N'),					 
					 USE_CNT     		= USE_CNT - 1,
					 CUSTOMERID  		= NULL,
					 ORDERNO	    		= NULL,
					 CONTRACTSEQ 		= NULL,
					 CUST_NO     		= NULL,
					 FIRST_CUSTOMER 	= decode(:ls_new_check,'Y',NULL,FIRST_CUSTOMER),
					 FIRST_SALEDT 		= decode(:ls_new_check,'Y',NULL,FIRST_SALEDT),
					 FIRST_SELLER 		= decode(:ls_new_check,'Y',NULL,FIRST_SELLER),
					 FIRST_PARTNER 	= decode(:ls_new_check,'Y',NULL,FIRST_PARTNER),
					 FIRST_SALE_AMT 	= decode(:ls_new_check,'Y',NULL,FIRST_SALE_AMT)	,					 
					 UPDT_USER   		= :gs_user_id,
					 UPDTDT		 		= SYSDATE						 
			WHERE  EQUIPSEQ    		= :ll_equipseq;
			
			IF SQLCA.SQLCODE < 0 THEN		//For Programer
				F_MSG_INFO(3010, Title, SQLCA.SQLERRTEXT + '~r~n ' + 'EQUIPMST UPDATE ERROR!')
				ROLLBACK;
				RETURN -1
			END IF	
	
	END IF
	
	IF ls_data_check = 'I' THEN 
		
	ELSE
		is_equipdate = 'Y'				//프로비저닝 종료후 update 치기 위해서!
  	END IF		

ELSEIF is_worktype = '200' THEN
	
	 IF ls_data_check = 'I' THEN
			
	 END IF		
	 
	 IF ls_data_check = 'R' THEN			
		is_equipdate = 'X'				//프로비저닝 종료후 update 치기 위해서!						
	 END IF		 
END IF	

IF is_equipdate = 'X' OR is_equipdate = 'Y' Then
		INSERT INTO EQUIPLOG
		(EQUIPSEQ,		SEQ,				LOGDATE,		LOG_STATUS,		SERIALNO,
		 CONTNO,			DACOM_MNG_NO,	MAC_ADDR,	MAC_ADDR2,		ADTYPE,
		 MAKERCD,		MODELNO,			STATUS,		VALID_STATUS,	USE_YN,
		 ADSTAT,			IDATE,			ISEQNO,		ENTSTORE,		MOVENO,
		 MV_PARTNER,	TO_PARTNER,		SN_PARTNER,	SNMOVEDT,		SALEDT,
		 RETDT,			CUSTOMERID,		CONTRACTSEQ,ORDERNO,			CUST_NO,
		 IDAMT,   	   SALE_AMT,		ITEMCOD,		SALE_FLAG,		REMARK,
		 SAP_NO,		 	NEW_YN,			USE_CNT,    CRT_USER,		CRTDT,
		 PGM_ID,			TROUBLE_CAUSE,	FIRST_CUSTOMER, FIRST_SALEDT, FIRST_SELLER,
		 FIRST_PARTNER, FIRST_SALE_AMT, CHANGE_REASON)
		SELECT EQUIPSEQ,	SEQ_EQUIPLOG.NEXTVAL,	SYSDATE, 	:ls_action, 	SERIALNO,
				 CONTNO,		DACOM_MNG_NO,				MAC_ADDR,	MAC_ADDR2,		ADTYPE,
				 MAKERCD,	MODELNO,						STATUS,		VALID_STATUS,	USE_YN,
				 ADSTAT,			IDATE,			ISEQNO,		ENTSTORE,		MOVENO,
				 MV_PARTNER,	TO_PARTNER,		SN_PARTNER,	SNMOVEDT,		SALEDT,
				 RETDT,			CUSTOMERID,		CONTRACTSEQ,ORDERNO,			CUST_NO,
				 IDAMT,   	   SALE_AMT,		ITEMCOD,		SALE_FLAG,		REMARK,			  
				 SAP_NO,		 	NEW_YN,			USE_CNT,    :gs_user_id,	SYSDATE,
				 :gs_pgm_id[gi_open_win_no],  TROUBLE_CAUSE,	FIRST_CUSTOMER, FIRST_SALEDT, FIRST_SELLER,
				 FIRST_PARTNER, FIRST_SALE_AMT, CHANGE_REASON
		FROM   EQUIPMST
		WHERE  EQUIPSEQ = :ll_equipseq;					

		IF SQLCA.SQLCODE < 0 THEN		//For Programer
			F_MSG_INFO(3010, Title, SQLCA.SQLERRTEXT + '~r~n ' + 'EQUIPLOG INSERT ERROR!')
			ROLLBACK;
			RETURN -1			
		END IF			
END IF



IF ls_data_check = "I" THEN
	dw_detail.Deleterow(0)
END IF

COMMIT;

ii_equipselect = ii_equipselect - 1

IF ii_equipselect < 0 THEN
	ii_equipselect = 0
END IF

F_MSG_INFO(3000, Title, 'SAVE')

PARENT.TRIGGER EVENT ue_retrieve_left()


RETURN 0
	

end event

type p_reset from u_p_reset within ubs_w_pop_equipvalid_nonvalid
integer x = 681
integer y = 1176
boolean bringtotop = true
boolean originalsize = false
end type

event clicked;Parent.TriggerEvent('ue_reset')
end event

type cb_1 from commandbutton within ubs_w_pop_equipvalid_nonvalid
boolean visible = false
integer x = 1463
integer y = 1176
integer width = 283
integer height = 96
integer taborder = 30
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "RETRY"
end type

event clicked;STRING	ls_data_check,		ls_errmsg,			ls_action,	ls_adtype,	&
			ls_first_adtype,	ls_second_adtype,	ls_work
LONG		ll_equipseq,		ll_return,			ll_row,				ll_return2
LONG		ll_contractseq,	ll_insert_equip	
INT		ii,					iii,					jj,					tt
LONG		ll_insert_case,	ll_retrie_case,	ll_delete_case,	ll_etc_case


dw_detail.AcceptText()

ll_row = dw_detail.RowCount()

IF ll_row <= 0 THEN
	f_msg_usr_err(210, Title, "임대/예약중 장비가 없습니다.")
	RETURN -1
END IF

//2009.06.12 로직 추가! 다양한 유형 때문에...
//케이스 정리
FOR jj = 1 TO ll_row
	ls_data_check = dw_detail.Object.data_check[jj]
	
	CHOOSE CASE ls_data_check
		CASE "I"
			ll_insert_case = ll_insert_case + 1
		CASE "R"
			ll_retrie_case = ll_retrie_case + 1
		CASE "D"
			ll_delete_case = ll_delete_case + 1			
		CASE ELSE
			ll_etc_case    = ll_etc_case + 1
	END CHOOSE
NEXT

IF ll_insert_case > 0 OR ll_delete_case > 0 THEN
	f_msg_usr_err(210, Title, "재인증 대상이 아닙니다.")
	RETURN -1
END IF

is_work = "RETRY"

SetNull(ll_equipseq)

IF is_worktype = '200' AND (IsNull(is_troubleno) OR is_troubleno <> "") THEN   //장애
	is_orderno = is_troubleno
END IF

IF is_work = "RETRY" THEN
	ll_return2 = wf_action_code(ls_action)
	
	IF ll_return2 < 0 THEN
		f_msg_usr_err(210, Title, "인증 ACTION 정보가 없습니다(wf_action_code2)")	
		RETURN -1
	END IF
		
	ls_errmsg = space(1000)
	SQLCA.UBS_PROVISIONNING(LONG(is_orderno),			ls_action,				ll_equipseq,		&
									'',							gs_shopid,										&
									gs_pgm_id[1],				ll_return,				ls_errmsg)
	
	IF SQLCA.SQLCODE < 0 THEN		//For Programer
		MESSAGEBOX(ls_errmsg, STRING(SQLCA.SQLCODE) + '~r~n ' + SQLCA.SQLERRTEXT)
		ROLLBACK;
		RETURN -1
	ELSEIF ll_return < 0 THEN		//For User
		MESSAGEBOX('확인', ls_errmsg,Exclamation!,OK!)
		ROLLBACK;		
		RETURN -1
	END IF
END IF

f_msg_info(3000, PARENT.Title, "Save")	

//수정된 내용이 없도록 하기 위해서 강제 세팅!
FOR ii = 1 TO ll_row
	dw_detail.SetItemStatus(ii, 0, Primary!, NotModified!)
NEXT

COMMIT;

RETURN 0
end event

type st_1 from statictext within ubs_w_pop_equipvalid_nonvalid
integer x = 2789
integer y = 28
integer width = 306
integer height = 64
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 33554432
long backcolor = 67108864
string text = "비인증장비"
boolean focusrectangle = false
end type

type gb_1 from groupbox within ubs_w_pop_equipvalid_nonvalid
integer x = 18
integer y = 8
integer width = 3072
integer height = 224
integer taborder = 20
integer textsize = -2
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
end type

