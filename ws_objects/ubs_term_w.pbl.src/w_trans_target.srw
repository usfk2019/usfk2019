$PBExportHeader$w_trans_target.srw
$PBExportComments$해지DB이관대상 고객추출
forward
global type w_trans_target from w_a_reg_m_m
end type
end forward

global type w_trans_target from w_a_reg_m_m
integer width = 4389
integer height = 2272
string title = "고객추출"
end type
global w_trans_target w_trans_target

type variables
TRANSACTION SQLCA_TERM

String is_operator, is_operatornm, is_partner
end variables

forward prototypes
public function integer wf_insert (string as_worktype)
public function integer wf_authority_check ()
end prototypes

public function integer wf_insert (string as_worktype);


//DW_MASTER 세팅

dw_master.insertrow(0)



dw_master.object.work_gubun[1] = as_worktype
dw_master.object.status [1] = '100'

IF as_worktype = '100' THEN
	dw_master.object.table_nm[1] = 'CUSTOMERM'
	dw_master.object.table_todo[1] =  'I'
ELSE
	dw_master.object.table_nm[1] = 'CUSTOMERM'
	dw_master.object.table_todo[1] =  'I'
END IF

dw_master.object.workdt_from[1] = dw_cond.object.fdate[1]
dw_master.object.workdt_to[1] = dw_cond.object.tdate[1]
dw_master.object.target_from[1] = dw_cond.object.fdate[1]
dw_master.object.target_to[1] = dw_cond.object.tdate[1]
dw_master.object.crt_user[1] = gs_user_id
dw_master.object.crtdt[1] = today()
dw_master.object.pgm_id = gs_pgm_id[gi_open_win_no]

return 0
end function

public function integer wf_authority_check ();
integer li_cnt

Select count(*) into :li_cnt
from Termcust.Syscod2t
where grcode = 'TERMUSER'
   and code = :gs_user_id;
	
if li_cnt = 0 then
	messagebox("확인","조회/처리 권한이 없습니다. 관리자에게 문의하세요")
	p_insert.TriggerEvent("ue_disable")
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_enable")
	return -1
end if
	
return 0
end function

on w_trans_target.create
call super::create
end on

on w_trans_target.destroy
call super::destroy
end on

event open;call super::open;
//TRANSACTION SQLCA_TERM
SQLCA_TERM = CREATE TRANSACTION 
SQLCA_TERM.DBMS  = "O84 ORACLE 8.0.4"
SQLCA_TERM.SERVERNAME = SQLCA.ServerName
SQLCA_TERM.LogId = "termcust"
SQLCA_TERM.LOGPASS = "termcust123"
SQLCA_TERM.AUTOCOMMIT = FALSE
CONNECT USING SQLCA_TERM;

IF SQLCA_TERM.SQLCODE < 0 THEN
	DISCONNECT USING SQLCA_TERM;
	DESTROY SQLCA_TERM;
	MESSAGEBOX("SQLCA_TERM CONNECT ERROR", "연결에 실패하였습니다. 관리자에게 문의하시기 바랍니다")
	RETURN
END IF

dw_cond.SetFocus()
dw_cond.SetColumn("work_type")
end event

event ue_ok;call super::ue_ok;
string  ls_work_type, ls_status, ls_fdate, ls_tdate, ls_operator, ls_fdate2, ls_tdate2, ls_pre_fdate, ls_pre_tdate, ls_new
date    ld_fdate, ld_tdate
long    ll_rows
int     li_cnt, li_fcnt, li_tcnt, li_ret

dw_master.settransobject(SQLCA_TERM)
dw_detail.settransobject(SQLCA_TERM)

dw_cond.accepttext()
dw_master.accepttext()

li_ret = 0
ls_work_type = fs_snvl(dw_cond.object.work_type[1], "")
ls_status    = fs_snvl(dw_cond.object.status[1], "")
ls_operator  = fs_snvl(dw_cond.object.operator[1], "")
ls_new    	= dw_cond.object.new[1]

//변경함 등록시 tartget_From, to 값이 대상일자값을 입력

ld_fdate     = dw_cond.object.fdate[1]
ld_tdate     = dw_cond.object.tdate[1]
ls_pre_fdate = dw_cond.object.pre_fdate[1]
ls_pre_tdate = dw_cond.object.pre_tdate[1]

SELECT   TO_CHAR(:ld_fdate, 'YYYYMMDD'), TO_CHAR(:ld_tdate, 'YYYYMMDD')
INTO     :ls_fdate, :ls_tdate
FROM     DUAL;


//권한체크
li_ret = wf_authority_check()
if li_ret < 0 then return
	

if ls_work_type = "" then
	f_msg_usr_err(9000, Title, "작업구분을 입력하여 주십시오.")
	return
end if

if ls_status = "" then
	f_msg_usr_err(9000, Title, "작업상태를 입력하여 주십시오.")
	return
end if

//Retrieve
	ll_rows = dw_master.retrieve(ls_work_type, ls_status, ls_fdate, ls_tdate)
	dw_master.trigger event rowfocuschanged(dw_master.getrow())

IF  ls_new = 'Y' THEN //'신규' 이면

	SELECT  COUNT(*)
	INTO    :li_fcnt
	FROM    TERMCUST.WORKLOG
	WHERE   WORKDT_FROM BETWEEN :ls_fdate AND :ls_tdate
		AND WORK_GUBUN = :ls_work_type
	//WHERE   :ls_fdate BETWEEN TARGET_FROM AND TARGET_TO
		AND STATUS = :ls_status;
	
	SELECT  COUNT(*)
	INTO    :li_tcnt
	FROM    TERMCUST.WORKLOG
	WHERE   WORKDT_TO BETWEEN :ls_fdate AND :ls_tdate
	//WHERE   :ls_tdate BETWEEN TARGET_FROM AND TARGET_TO
		AND WORK_GUBUN = :ls_work_type
		AND STATUS = :ls_status;

	IF (li_fcnt > 0 or li_tcnt > 0) and ls_status = '100' and ll_rows > 0  Then
		messagebox("확인", "대상 시작일자나 종료일자가 기존 추출날짜와 중복되니 확인 후 작업하세요.")
	
		p_insert.TriggerEvent("ue_disable")
		p_delete.TriggerEvent("ue_disable")
		p_save.TriggerEvent("ue_disable")
		
		return
	END IF

	if ls_work_type = '100' and li_cnt = 0 and ll_rows = 0 then //해지자이관
		if ls_status = '100' then   //상태가 추출일경우만 조회함
		     li_ret = messagebox("확인", "해지자이관 대상자 추출작업을 시작하시겠습니까?", Exclamation!, YESNO!, 2)
			if li_ret = 1 then
				//wf_insert(ls_work_tyep)
				dw_detail.retrieve( 0, '1', ls_pre_fdate, ls_pre_tdate)
			end if
		end if
	elseif 	ls_work_type = '200' and li_cnt = 0 and ll_rows = 0 then 		//보유기간만료
		if ls_status = '100' then //상태가 추출일경우만 조회함
		     li_ret = messagebox("확인", "보유기간만료 대상자 추출작업을 시작하시겠습니까?", Exclamation!, YESNO!, 2)
			if li_ret = 1 then				
				dw_detail.retrieve( 0, '3', ls_pre_fdate, ls_pre_tdate)
			end if
			
		end if
	end if

END IF



//if ls_work_type = '100' and ls_status = '100'  then
//	IF (li_fcnt > 0 or li_tcnt > 0) and ls_status = '100' and ll_rows > 0 Then
//		messagebox("확인", "대상 시작일자나 종료일자가 기존 추출날짜와 중복되니 확인 후 작업하세요.")
//	
//		p_insert.TriggerEvent("ue_disable")
//		p_delete.TriggerEvent("ue_disable")
//		p_save.TriggerEvent("ue_disable")
//	END IF
//end if



dw_cond.SetFocus()
dw_cond.SetColumn("fdate")

if ls_status = '200' then //처리완료
	p_insert.TriggerEvent("ue_disable")
	p_delete.TriggerEvent("ue_disable")
	p_save.TriggerEvent("ue_disable")
	p_reset.TriggerEvent("ue_enable")
else
	p_insert.TriggerEvent("ue_enable")
	p_delete.TriggerEvent("ue_enable")
	p_save.TriggerEvent("ue_enable")
	p_reset.TriggerEvent("ue_enable")
end if

//dw_cond.Enabled = True
		

end event

event ue_save;Constant Int LI_ERROR = -1
int    li_return
string ls_work_type , ls_stauts, ls_customer_id, ls_remark, ls_operator
string ls_pre_fdate, ls_pre_tdate, ls_flag
string ls_fdate, ls_tdate
date   ld_fdate, ld_tdate, ld_work_fdate, ld_work_tdate
long   ll_work_no, ll_rowcnt, ll_rcnt, ll_row, i
dwItemStatus l_status

dw_cond.accepttext()
dw_detail.AcceptText()

ll_rowcnt = dw_master.rowcount()
ll_rcnt   = dw_detail.rowcount()

ls_work_type   = dw_cond.object.work_type[1]
ld_fdate       = dw_cond.object.fdate[1] 
ld_tdate       = dw_cond.object.tdate[1] 
ls_operator    = dw_cond.object.operator[1] 
ls_stauts      = dw_cond.object.status[1] 



//변경함 등록시 tartget_From, to 값이 대상일자값을 입력
ls_pre_fdate   = dw_cond.object.pre_fdate[1] 
ls_pre_tdate   = dw_cond.object.pre_tdate[1] 
ld_work_fdate       = date(ls_pre_fdate)
ld_work_tdate       = date(ls_pre_tdate)

if ls_stauts  = '200' then
	messagebox('확인', '처리완료 상태에서는 변경 불가 합니다.')
	Trigger Event ue_ok()
	return -1
end if

if ll_rowcnt > 0 then
	ll_row = dw_master.getrow()
	ll_work_no = dw_master.object.workno[ll_row]
end if

// 해지자, 보유기간만료 추출 등록을 할 경우
if ll_rowcnt = 0 then	
	if ll_rcnt = 0  then 
		messagebox('확인', '추출할 데이터가 존재하지 않습니다.')
		return -1
	end if
	
	//작업번호 생성
	SELECT TERMCUST.SEQ_WORKNO.NEXTVAL
	INTO   :ll_work_no
	FROM   DUAL;
	
	for i = 1 to ll_rcnt
		
		ls_customer_id = fs_snvl(dw_detail.object.customerid[i], "") 
		ls_remark      = dw_detail.object.remark[i] 
		ls_flag        = dw_detail.object.flag[i] 
		
		If trim(ls_customer_id) = '' Then 
			messagebox('확인', '고객번호 입력은 필수 사항입니다.!')
			Return -1
		end if
	
		//TRANS_TARGET INSERT
		INSERT INTO TERMCUST.TRANS_TARGET (
					WORKNO, WORK_GUBUN, CUSTOMERID, 
					REMARK, FLAG, CRT_USER, 
					UPDT_USER, CRTDT, UPDTDT, 
					PGM_ID) 
		VALUES ( :ll_work_no  , :ls_work_type, :ls_customer_id,
					:ls_remark   , :ls_flag	    , :ls_operator, 
					NULL         , SYSDATE      , NULL,
					:gs_pgm_id[gi_open_win_no]);
					
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(title, SQLCA.SQLErrText+ " Insert Error(TRANS_TARGET)")
			RollBack using  SQLCA_TERM;
			Return -1
		End If		
	next
	
	//WORKLOG INSERT
	INSERT INTO TERMCUST.WORKLOG (
				WORKNO, WORK_GUBUN, STATUS, 
				TABLE_NM, TABLE_TODO, TARGET_FROM, 
				TARGET_TO, DATA_CNT, CRT_USER, 
				UPDT_USER, CRTDT, UPDTDT,
				PGM_ID, WORKDT_FROM, WORKDT_TO) 
	VALUES ( :ll_work_no  , :ls_work_type , :ls_stauts,
				'CUSTOMERM'  , 'Insert'      , :ld_work_fdate, 
				:ld_work_tdate    , :ll_rcnt      , :ls_operator,
				NULL , SYSDATE      , NULL,
				:gs_pgm_id[gi_open_win_no], :ld_fdate , :ld_tdate);
//	VALUES ( :ll_work_no  , :ls_work_type , :ls_stauts,
//				'CUSTOMERM'  , 'Insert'      , :ld_fdate, 
//				:ld_tdate    , :ll_rcnt      , :ls_operator,
//				NULL , SYSDATE      , NULL,
//				:gs_pgm_id[gi_open_win_no], :ld_work_fdate , :ld_work_tdate);
				
	If SQLCA_TERM.SQLCode < 0 Then
		f_msg_sql_err(title, SQLCA.SQLErrText+ " Insert Error(WORKLOG)")
		RollBack using  SQLCA_TERM;
		Return -1
	End If	
	
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3000,This.Title,"Save")
	
else //remark등 컬럼 업데이트
	for i = 1 to ll_rcnt		
		l_status = dw_detail.GetItemStatus(i, 0, Primary!)
		IF l_status = New! or l_status = NewModified! or l_status = DataModified! then
			
			ls_customer_id = fs_snvl(dw_detail.object.customerid[i], "") 
			If trim(ls_customer_id) = '' Then 
				messagebox('확인', '고객번호 입력은 필수 사항입니다.!')
				Return -1
			end if
			
			if l_status = DataModified! then
				dw_detail.setitem( i, 'UPDT_USER', is_operator)
				dw_detail.setitem( i, 'UPDTDT', Date(fdt_get_dbserver_now()))
			end if
		end if
	next
	
	if dw_detail.update() <> 1 then
		f_msg_info(3010,This.Title,"Save")
		rollback using  SQLCA_TERM;
		return -1
	else
		//worklog 에 변경된 data건수를 update한다.
	     update worklog set
		  	data_cnt = :ll_rcnt
	     where workno = :ll_work_no
		using SQLCA_TERM;
		
		commit using  SQLCA_TERM;
		f_msg_info(3000,This.Title,"Save")
	end if

End If
Trigger Event ue_ok()

Return 0

end event

event ue_extra_save;//Long		ll_mst_row, ll_det_rowcnt, i, ll_contractseq, ll_contractseq_ori
//String	ls_partner, ls_operator, ls_selection, ls_itemcod, ls_request_status, ls_req_code, ls_customerid, ls_ins_yn, ls_settle_partner
//Date		ld_bil_fromdt, ld_bil_todt
//
////Get Mst RowCount
//ll_mst_row = dw_master.GetSelectedRow(0)
//
//IF ll_mst_row < 1 THEN Return -1
//
//
////Get Det RowCount
//ll_det_rowcnt = dw_detail.RowCount()
//
//IF ll_det_rowcnt < 1 THEN Return -1
//
//
////Condition
//ls_partner  = dw_cond.Object.partner[1]
//ls_operator = dw_cond.Object.operator[1]
//
//If f_nvl_chk(dw_cond, 'partner', 1, ls_partner, '')   = False Then Return -1
//If f_nvl_chk(dw_cond, 'operator', 1, ls_operator, '') = False Then Return -1
//
////Get Mst Info
//ls_customerid      = dw_master.Object.contractmst_customerid[ll_mst_row]
//ll_contractseq_ori = dw_master.Object.contractseq[ll_mst_row]
//ls_settle_partner  = dw_master.object.contractmst_settle_partner[ll_mst_row]
//
//
//
////Row별 처리
//FOR i=1 TO ll_det_rowcnt
//
//	ls_selection      = dw_detail.Object.selection[i]
//	ls_itemcod        = dw_detail.Object.itemcod[i]
//	ld_bil_fromdt     = Date(dw_detail.Object.bil_fromdt[i])
//	ld_bil_todt       = Date(dw_detail.Object.bil_todt[i])
//	ls_request_status = dw_detail.Object.request_status[i]
//	ls_req_code       = dw_detail.Object.req_code[i]				//SVCADD, SVCDEL
//	ll_contractseq    = dw_detail.Object.contractseq[i]
////	ls_settle_partner = dw_detail.Object.settle_partner[i]
//	
////	If f_nvl_chk(dw_detail, 'settle_partner', i, ls_settle_partner, '개통처를 선택하세요') = False Then
////		Rollback;
////		Return -1
////	End If
//	
//	//유효성 체크
//	IF ls_request_status = "Y" THEN CONTINUE;
//	
//	//개통처세팅
//	if isnull(ls_settle_partner) or ls_settle_partner = '' then
//	         
//				//1.admst에서 찾는다.
//				SELECT REF_CODE1 INTO :ls_settle_partner
//				FROM SYSCOD2T
//				WHERE GRCODE = 'B816'
//				  AND CODE = (   select entstore from admst
//                where customerid = :ls_customerid
//                 and contractseq = :ll_contractseq);
//					  
//					  
//			  if isnull(ls_settle_partner) or ls_settle_partner = '' then 
//				      //2.admstlog_new에서 찾는다.
//				      SELECT REF_CODE1 INTO :ls_settle_partner
//                    FROM SYSCOD2T
//                    WHERE GRCODE = 'B816'
//                      AND CODE = (  select entstore from admst where adseq in ( select distinct adseq from admstlog_new
//                         where customerid =  :ls_customerid
//                          and contractseq = :ll_contractseq));
//			  end if
//			  if isnull(ls_settle_partner) or ls_settle_partner = '' then 
//				      //3. admstlog_new 에도 정보가 없으면 메세지 띄운다.
//			  			messagebox("확인", "개통처가 입력되지 않았습니다. 관리자에게 연락하세요.")
//				else
//					dw_detail.Object.settle_partner[i] = ls_settle_partner
//			  end if
//	end if
//	
//	
//	//취소건 체크
//	IF ls_selection = "N" AND IsNull(ll_contractseq) = False THEN
//		ls_ins_yn   = 'Y'
//		ld_bil_todt = Date(fdt_get_dbserver_now())
//		
//	//등록건
//	ELSEIF ls_selection = "Y" AND IsNull(ll_contractseq) or string(ld_bil_todt) <> ''  THEN
//		ls_ins_yn     = 'Y'
//		ld_bil_fromdt = Date(fdt_get_dbserver_now())
//		
//	ELSE
//		ls_ins_yn = 'N'
//	END IF	
//	
//	//부가서비스 취소 신청
//	IF ls_ins_yn = "Y" THEN
//		
//		INSERT INTO SVC_REQ_MST (
//						REQNO
//					 , REQ_CODE,     REQDT,          CUSTOMERID,     CONTRACTSEQ,         ITEMCOD,     BIL_FROMDT
//					 , BIL_TODT,     COMEPLETE_YN,   FR_SHOP,        FR_OPER,             FR_CRTDT,    TO_SHOP )
//			  VALUES (
//						SEQ_SVC_REQ_MST.NEXTVAL
//					 , :ls_req_code, TRUNC(SYSDATE), :ls_customerid, :ll_contractseq_ori, :ls_itemcod, :ld_bil_fromdt
//					 , :ld_bil_todt, 'N',            :ls_partner,    :ls_operator,        SYSDATE,     :ls_settle_partner
//					 )
//					 ;
//		IF SQLCA.SQLCODE <> 0 Then
//			f_msg_sql_err(SQLCA.SQLERRTEXT, "Insert SVC_REQ_MST Fail. (CONTRACTSEQ=" + String(ll_contractseq_ori) + ")")
//			Rollback;
//			Return -1
//		END IF
//	END IF
//NEXT
//
////No Error
RETURN 0
end event

event ue_reset;call super::ue_reset;dw_cond.trigger event ue_init()

return 0
end event

event ue_insert;call super::ue_insert;/*insert(dw_detail) 경우의 수*/
/*1. 추출완료된 데이터가 조회 되었을 경우 추가*/
/*2. 추출완료 데이터를 등록하기 전에 추가로 삽입의 경우*/

int    li_cnt, li_cnt2, li_row, li_row2
string ls_status, ls_work_type, ls_gubun_nm
long   ll_work_no, ll_ref_workno

dw_cond.accepttext()
dw_master.accepttext()
dw_detail.accepttext()

ls_work_type= dw_cond.object.work_type[1] 
ls_status   = dw_cond.object.status[1] 

li_cnt      = dw_master.rowcount()
li_cnt2     = dw_detail.rowcount()

li_row = dw_master.getrow()
if li_row > 0 then
	ll_ref_workno = dw_master.object.ref_workno[li_row]
end if

SELECT  CODENM
INTO    :ls_gubun_nm
FROM    TERMCUST.SYSCOD2T
WHERE   GRCODE = 'TERM100' AND CODE = :ls_work_type;

if li_cnt2 = 0 then
	li_row2 = 1 
else
	li_row2     = dw_detail.getrow()    //insertrow 
end if

if ll_ref_workno > 0 then  
	messagebox('확인', '처리작업번호가 발생한 건은  변경 불가 합니다.!')
	dw_detail.DeleteRow(li_row2)
	//trigger event ue_delete()
	return -1
end if

// 추출완료된 데이터에 insert
if li_cnt > 0 then
	
	ll_work_no = dw_master.object.workno[li_row]

	dw_detail.setitem( li_row2, 'workno', ll_work_no)
	dw_detail.setitem( li_row2, 'work_gubun', ls_work_type)
	dw_detail.setitem( li_row2, 'gubun_nm', ls_gubun_nm)
	dw_detail.setitem( li_row2, 'flag', 'I')
	dw_detail.setitem( li_row2, 'CRT_USER', is_operator)
	dw_detail.setitem( li_row2, 'CRTDT', Date(fdt_get_dbserver_now()))
	dw_detail.setitem( li_row2, 'PGM_ID', gs_pgm_id[gi_open_win_no])
	dw_detail.selectrow(li_row2, true)
else
	dw_detail.setitem( li_row2, 'flag', 'I')
	dw_detail.setitem( li_row2, 'CRT_USER', is_operator)
	dw_detail.setitem( li_row2, 'CRTDT', Date(fdt_get_dbserver_now()))
	dw_detail.setitem( li_row2, 'PGM_ID', gs_pgm_id[gi_open_win_no])
	dw_detail.selectrow(li_row2, true)
end if

return 1

end event

event ue_delete;int    li_cnt, li_row, li_row_master
long   ll_work_no, ll_ref_workno

dw_master.accepttext()
dw_detail.accepttext()

li_cnt     = dw_detail.RowCount()
li_row     = dw_detail.getrow()
ll_work_no = dw_detail.object.workno[li_row]

li_row_master = dw_master.getrow()
if li_row_master > 0 then
	ll_ref_workno = dw_master.object.ref_workno[li_row_master]
end if 
if ll_ref_workno > 0 then  
	messagebox('확인', '처리작업번호가 발생한 건은  변경 불가 합니다.!')
	return -1
end if


if li_cnt > 0 then
	//if isNull(ll_work_no) = true then
		dw_detail.DeleteRow(0)
		dw_detail.SetFocus()
//	else
//		dw_detail.setitem(li_row, 'flag', 'D')
//		dw_detail.setitem(li_row, 'UPDT_USER', is_operator)
//		dw_detail.setitem(li_row, 'UPDTDT', Date(fdt_get_dbserver_now()))
//	end if
end if

return 0 

end event

type dw_cond from w_a_reg_m_m`dw_cond within w_trans_target
integer y = 64
integer width = 3145
integer height = 284
string dataobject = "d_cnd_trans_target"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::itemchanged;call super::itemchanged;String 	ls_operator, ls_empnm, ls_partner	
string   ls_pre_fdate, ls_pre_tdate , ls_date_string, ls_work_type
int      li_cnt, li_cnt2
date     ld_fdate, ld_tdate, ld_expire_month

dw_cond.accepttext()

ls_work_type = dw_cond.object.work_type[1]

//기준개월 찾기
SELECT TO_NUMBER(REF_DESC) 
INTO   :li_cnt
FROM   TERMCUST.SYSCTL1T
WHERE  MODULE=  'A1'  AND REF_NO = '200' ;

//보유기간 만료고객 추출
SELECT TO_NUMBER(REF_DESC) 
INTO   :li_cnt2
FROM   TERMCUST.SYSCTL1T
WHERE  MODULE=  'A1'  AND REF_NO = '400' ;

Choose Case dwo.name

	case 'operator'
		SELECT EMPNM, EMP_GROUP INTO :ls_empnm, :ls_partner
		FROM   SAMS.SYSUSR1T
		WHERE  EMP_NO = :data;
		
		IF IsNull(ls_empnm) OR ls_empnm = "" THEN
			f_msg_usr_err(9000, Title, "Operator 를 확인하세요!")
			dw_cond.SetFocus()
			dw_cond.SetRow(row)
			dw_cond.object.operator[row]		= ""
			dw_cond.object.operatornm[row]	= ""
			dw_cond.SetColumn("operator")
			RETURN 2			
		END IF
		
		dw_cond.object.operatornm[row] = ls_empnm
		
		is_operator   = data
		is_operatornm = ls_empnm
		//is_partner    = ls_partner
		
	case 'fdate', 'tdate'
		ld_fdate = this.object.fdate[row]
		ld_tdate = this.object.tdate[row]
		
		if ls_work_type = '100'  then			//기준개월전 일자
			SELECT  TO_CHAR(ADD_MONTHS(:ld_fdate, -:li_cnt),'YYYY-MM-DD'),
					  TO_CHAR(ADD_MONTHS(:ld_tdate, -:li_cnt),'YYYY-MM-DD')
			INTO    :ls_pre_fdate, :ls_pre_tdate
			FROM    DUAL;
	
			ls_date_string = '(' + ls_pre_fdate + ' ~~ ' + ls_pre_tdate + ' )'
	
			this.object.pre_date.text = ls_date_string
			this.object.pre_fdate[1]  = ls_pre_fdate
			this.object.pre_tdate[1]  = ls_pre_tdate	
		else 			//보유만료기간 셋팅
			ld_fdate = this.object.fdate[row]
			ld_tdate = this.object.tdate[row]
			
			SELECT  TO_CHAR(ADD_MONTHS(:ld_fdate, -:li_cnt2),'YYYY-MM')||'-01',
					   TO_CHAR(LAST_DAY(ADD_MONTHS(:ld_tdate, -:li_cnt2)),'YYYY-MM-DD')
			INTO    :ls_pre_fdate, :ls_pre_tdate
			FROM    DUAL;
			
			ls_date_string = '(' + ls_pre_fdate + ' ~~ ' + ls_pre_tdate + ' )'
			this.object.pre_date.text = ls_date_string
			this.object.pre_fdate[1]  = ls_pre_fdate
			this.object.pre_tdate[1]  = ls_pre_tdate			
		end if

	case 'work_type'
		trigger event itemchanged(1, this.object.fdate, '')
		
	case 'new'
		this.object.status[1] = '100' //추출

End Choose

end event

event dw_cond::ue_init;call super::ue_init;//조회조건 초기화
//작업구분 작업상태 operator 대상일자등 셋팅

string ls_pre_date, ls_date_string
int    li_cnt

this.Object.fdate[1] = Date(fdt_get_dbserver_now())
this.Object.tdate[1] = Date(fdt_get_dbserver_now())

this.Object.expire_month[1] = Date(fdt_get_dbserver_now())

f_dddw_list2(this, 'work_type', 'TERM100')
f_dddw_list2(this, 'status', 'TERM101')

dw_cond.object.operator[1] = gs_user_id

//operator명 
trigger event itemchanged(1, this.object.operator, gs_user_id)

//대상일자 변경에 따른 실 대상 일자 셋팅
trigger event itemchanged(1, this.object.fdate, '')



end event

type p_ok from w_a_reg_m_m`p_ok within w_trans_target
integer x = 3415
end type

type p_close from w_a_reg_m_m`p_close within w_trans_target
integer x = 3721
end type

type gb_cond from w_a_reg_m_m`gb_cond within w_trans_target
integer width = 3186
integer height = 380
integer taborder = 20
end type

type dw_master from w_a_reg_m_m`dw_master within w_trans_target
integer y = 412
integer width = 4151
integer height = 644
integer taborder = 30
string dataobject = "d_inq_trans_target"
end type

event dw_master::retrieveend;call super::retrieveend;//If rowcount > 0 Then
//	p_ok.TriggerEvent("ue_disable")
//	
//	
////	p_insert.TriggerEvent("ue_enable")
////	p_delete.TriggerEvent("ue_enable")
//	//p_save.TriggerEvent("ue_enable")
//	p_reset.TriggerEvent("ue_enable")
//	
//	dw_cond.Enabled = False
//End If
end event

event dw_master::rowfocuschanged;call super::rowfocuschanged;long ll_workno
string ls_work_type,ls_pre_fdate, ls_pre_tdate, ls_status

dw_cond.accepttext()

ls_work_type = dw_cond.object.work_type[1]

If currentrow <= 0 Then
	Return
Else
	SelectRow(0, False)
	ScrollToRow(currentrow)
	SelectRow(currentrow, True)
	
	dw_detail.Reset()
	ll_workno     = this.object.workno[currentrow]
	ls_pre_fdate  = dw_cond.object.pre_fdate[1]
	ls_pre_tdate  = dw_cond.object.pre_tdate[1]
	ls_status     = dw_cond.object.status[1]
	
	if ls_work_type =  '100' then
 		dw_detail.retrieve(ll_workno, '0', ls_pre_fdate, ls_pre_tdate)
	else
		dw_detail.retrieve(ll_workno, '2', ls_pre_fdate, ls_pre_tdate)
	end if	
end if
end event

event dw_master::clicked;/*sort  에러처리 잡아야함*/

if row = 0 then return


end event

event dw_master::doubleclicked;call super::doubleclicked;
if row = 0 then return

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "고객별계약확인"
//iu_cust_msg.is_grp_name = "계약확인"
iu_cust_msg.idw_data[1] = dw_master
iu_cust_msg.is_data[2] = Trim(String(This.object.workno[row]))
iu_cust_msg.il_data[1] = row
		
OpenWithParm(w_pop_trans_target, iu_cust_msg)
end event

type dw_detail from w_a_reg_m_m`dw_detail within w_trans_target
integer y = 1112
integer width = 4165
integer height = 896
integer taborder = 40
string dataobject = "d_reg_trans_target"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)

end event

event dw_detail::ue_retrieve;//string   ls_fdate, ls_tdate

//String	ls_where, ls_contractseq, ls_priceplan
//String 	ls_partner, ls_sn_partner, ls_settle_partner
//Long		ll_contractseq, ll_rows = 0
//integer li_cnt
//
////Retrieve
//If al_select_row > 0 Then
//	//Get Search Condition
//	ll_contractseq    = dw_master.Object.contractseq[al_select_row]
//	ls_priceplan      = dw_master.Object.priceplan[al_select_row]	
//	ls_settle_partner = dw_master.Object.contractmst_settle_partner[al_select_row]	
//	
//	ll_rows = dw_detail.Retrieve(ll_contractseq, ls_priceplan)	
//	If ll_rows < 0 Then
//		f_msg_usr_err(2100, Parent.Title, "Retrieve()")
//		Return -1
//	ElseIf ll_rows = 0 Then
//		f_msg_info(1000, Title, "")
//		//Return 1
//	End If
//End if
//
////이미 오늘 신청중인 계약이면 save안되게
//select count(*) into :li_cnt
//from svc_req_mst
//where contractseq = :ll_contractseq
//  and reqdt = trunc(sysdate)
//  and req_code in ('SVCADD','SVCDEL');  
//
//
////1건이상 조회되면 조회버튼 활성화
//If ll_rows > 0   and li_cnt = 0 Then
////If ll_rows > 0  Then
//	p_save.TriggerEvent("ue_enable")
////	//Shop
////	ls_partner = fs_snvl(dw_cond.Object.partner[1], "")
////	
////	//장비판매 대리점
////	ls_sn_partner = fs_snvl(this.Object.admst_sn_partner[1], "")
////	
////	If ls_partner <> ls_sn_partner Then
////		p_save.TriggerEvent("ue_disable")
////		f_msg_usr_err(9000, Title, "입력한 Shop과 단말판매 Shop이 다릅니다.")
////		Return -1
////	End If
//Else
//	p_save.TriggerEvent("ue_disable")
//End If
//
Return 0
end event

event dw_detail::itemchanged;call super::itemchanged;string  ls_cust_id
int     li_rowcnt, i, li_cnt = 0

choose case dwo.name
	case 'customerid'
		li_rowcnt  =  this.rowcount()
		for i = 1 to li_rowcnt
			ls_cust_id = this.object.customerid[i]
			if ls_cust_id = data then
				li_cnt = li_cnt + 1
				if li_cnt >1 then
					messagebox('확인', '중복된 고객번호가 있습니다!!')
					dw_detail.SetFocus()
					dw_detail.SetRow(row)
					dw_detail.object.customerid[row]	= ""
					dw_detail.setcolumn('customerid')
					return 2
				end if
			end if
		next
End Choose


end event

event dw_detail::clicked;call super::clicked;
If row = 0 then Return

If IsSelected( row ) then
	//SelectRow( row ,FALSE)
Else
   SelectRow(0, FALSE )
	SelectRow( row , TRUE )
End If


end event

type p_insert from w_a_reg_m_m`p_insert within w_trans_target
integer x = 50
integer y = 2032
end type

type p_delete from w_a_reg_m_m`p_delete within w_trans_target
integer x = 343
integer y = 2032
end type

type p_save from w_a_reg_m_m`p_save within w_trans_target
integer x = 635
integer y = 2032
boolean enabled = true
end type

type p_reset from w_a_reg_m_m`p_reset within w_trans_target
integer x = 928
integer y = 2032
boolean enabled = true
end type

event p_reset::clicked;call super::clicked;dw_cond.trigger event ue_init()
end event

type st_horizontal from w_a_reg_m_m`st_horizontal within w_trans_target
integer y = 1068
end type

