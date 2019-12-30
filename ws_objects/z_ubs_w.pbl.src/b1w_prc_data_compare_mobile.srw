$PBExportHeader$b1w_prc_data_compare_mobile.srw
$PBExportComments$모바일 개통처 비교레포트 - 2015-03-25. lys
forward
global type b1w_prc_data_compare_mobile from w_a_reg_m_tm2
end type
type st_1 from statictext within b1w_prc_data_compare_mobile
end type
type st_2 from statictext within b1w_prc_data_compare_mobile
end type
type sle_filename from singlelineedit within b1w_prc_data_compare_mobile
end type
type mle_filedesc from multilineedit within b1w_prc_data_compare_mobile
end type
type dw_temp from u_d_sgl_sel within b1w_prc_data_compare_mobile
end type
type p_find from u_p_find within b1w_prc_data_compare_mobile
end type
type p_fileread from u_p_fileread within b1w_prc_data_compare_mobile
end type
type cb_create from commandbutton within b1w_prc_data_compare_mobile
end type
type p_saveas from u_p_saveas within b1w_prc_data_compare_mobile
end type
type gb_file from gb_cond within b1w_prc_data_compare_mobile
end type
end forward

global type b1w_prc_data_compare_mobile from w_a_reg_m_tm2
integer width = 5038
integer height = 2624
event type integer ue_fileread ( )
event type boolean ue_find ( )
event type boolean ue_process ( )
event type boolean ue_fileread2 ( )
event ue_saveas ( )
st_1 st_1
st_2 st_2
sle_filename sle_filename
mle_filedesc mle_filedesc
dw_temp dw_temp
p_find p_find
p_fileread p_fileread
cb_create cb_create
p_saveas p_saveas
gb_file gb_file
end type
global b1w_prc_data_compare_mobile b1w_prc_data_compare_mobile

type prototypes
Function Long SetCurrentDirectoryA (String lpPathName ) Library "kernel32" 
end prototypes

type variables

string is_file, is_partner, is_fileName
end variables

forward prototypes
public function integer wfi_cut_string (string as_source, string as_cut, ref string as_result[])
public function integer wf_create_rate_mobile (string as_fromdt, integer ai_seq)
end prototypes

event ue_fileread;
//Long		ll_cnt = 0, ll_add_row, ll_row, ll_rtn_cnt, ll_filerow = 0	
String   ls_operator, ls_partner, ls_svc_type, ls_filename, ls_file_desc, ls_validkey
Date     ld_reqdt
Long		ll_maxseq, ll_filerow, ll_rtn_cnt, ll_cnt, ll_row
Int		li_rtn
Int  		lb_return = -1


//필수값 Check
dw_cond.AcceptText()

ls_operator = dw_cond.object.operator[1]
ls_partner  = dw_cond.object.partner[1]

ld_reqdt    = dw_cond.object.reqdt[1]
If f_nvl_chk(dw_cond, 'reqdt', 1, String(ld_reqdt), '') = False Then Return -1

//ls_svc_type = dw_cond.object.svc_type[1]
//If f_nvl_chk(dw_cond, 'svc_type', 1, ls_svc_type, '') = False Then Return lb_return

ls_filename = sle_filename.text 
IF is_file = "" or IsNull(is_file) THEN
	f_msg_info(200, "", "파일명을 입력하세요.")
	sle_filename.SetFocus()
	RETURN -1
END IF

ls_file_desc = trim(mle_filedesc.text)

IF ls_file_desc = '' THEN
	f_msg_info(200, "", "파일설명을 입력하세요.")
	mle_filedesc.SetFocus()
	p_fileread.TriggerEvent("ue_enable")
	RETURN 1
END IF


//파일 임포트
dw_temp.reset()
ll_rtn_cnt = dw_temp.ImportFile(is_file)

//임포트 에러 메세지
Choose case ll_rtn_cnt
	case  0
		Messagebox("Information",'End of file; too many rows ') 
		RETURN lb_return
	CASE -1   
		MessageBox('Information', 'No rows') 
		RETURN lb_return
	CASE -2   
		MessageBox('Information', 'Empty file') 
		RETURN lb_return
	CASE -3   
		MessageBox('Information', 'Invalid argument') 
		RETURN lb_return
	CASE -4   
		MessageBox('Information', 'Invalid input') 
		RETURN lb_return
	CASE -5   
		MessageBox('Information', 'Could not open the file') 
		RETURN lb_return
	CASE -6   
		MessageBox('Information', 'Could not close the file') 
		RETURN lb_return
	CASE -7   
		MessageBox('Information', 'Error reading the text') 
		RETURN lb_return
	CASE -8   
		MessageBox('Information', 'Not a TXT file') 
		RETURN lb_return
	CASE -9   
		MessageBox('Information', 'The user canceled the import') 
		RETURN lb_return
	CASE ELSE
//		//txt파일 삭제
//		If FileExists(is_file) Then
//			FileDelete(is_file)
//		End If
END CHOOSE 



//원본자료로 생성
SELECT NVL(MAX(SEQ), 0) + 1 INTO :ll_maxseq
  FROM MOBILE_COMPARE_LOG
 WHERE 1=1
   AND AGENT_CD = :gs_shopid
	AND REQDT    = :ld_reqdt
	;
	
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(SQLCA.SQLERRTEXT, "GET MAX SEQ Fail. ([MOBILE_COMPARE_LOG]AGENT_CD=" +gs_shopid+ ", REQDT=" +String(ld_reqdt)+ ", SVC_TYPE=" +ls_svc_type+ ")")
	Return lb_return
End If	


//초기화
ll_filerow = dw_temp.rowcount()
tab_1.idw_tabpage[1].reset()
ll_cnt = 0

tab_1.idw_tabpage[1].SetRedraw(False)
FOR ll_row = 1 to ll_filerow
	
	//Data Check
	If ld_reqdt <> Date(dw_temp.Object.reqdt[ll_row]) Then
		ROLLBACK;
		MessageBox('Information', "비교일자와 데이터의 신청일자가 다릅니다! (" + String(ll_row, '#,##0') + "Line, "+String(dw_temp.Object.reqdt[ll_row], 'YYYY-MM-DD')+")")
		RETURN lb_return		
	End If
	
	//Set Count
	ll_cnt += 1
	
	//Insert Row
	tab_1.idw_tabpage[1].InsertRow(ll_row)
	
	//인증키 변환
	IF MID(dw_temp.Object.validkey[ll_row], 1, 1) = '1' THEN ls_validkey = '01' ELSE ls_validkey = '1'
	ls_validkey += MID(dw_temp.Object.validkey[ll_row], 2)
	
	//Set Row
	tab_1.idw_tabpage[1].Object.agent_cd[ll_row]       = ls_partner
	tab_1.idw_tabpage[1].Object.reqdt[ll_row]          = dw_temp.Object.reqdt[ll_row]
	tab_1.idw_tabpage[1].Object.seq[ll_row]            = ll_maxseq
	tab_1.idw_tabpage[1].Object.svc_type[ll_row]       = dw_temp.Object.svc_type[ll_row]
	tab_1.idw_tabpage[1].Object.shop[ll_row]           = dw_temp.Object.shop[ll_row]
	tab_1.idw_tabpage[1].Object.operator[ll_row]       = dw_temp.Object.operator[ll_row]
	tab_1.idw_tabpage[1].Object.validkey[ll_row]       = ls_validkey
	tab_1.idw_tabpage[1].Object.priceplan[ll_row]      = dw_temp.Object.priceplan[ll_row]
	tab_1.idw_tabpage[1].Object.sms_yn[ll_row]         = dw_temp.Object.sms_yn[ll_row]
	tab_1.idw_tabpage[1].Object.modelno[ll_row]        = dw_temp.Object.modelno[ll_row]
	tab_1.idw_tabpage[1].Object.serialno[ll_row]       = dw_temp.Object.serialno[ll_row]
	tab_1.idw_tabpage[1].Object.contno[ll_row]         = dw_temp.Object.contno[ll_row]
	tab_1.idw_tabpage[1].Object.usimno[ll_row]         = dw_temp.Object.usimno[ll_row]
	tab_1.idw_tabpage[1].Object.term_amt[ll_row]       = dw_temp.Object.term_amt[ll_row]
	tab_1.idw_tabpage[1].Object.validkey_check[ll_row] = dw_temp.Object.validkey_check[ll_row]
	tab_1.idw_tabpage[1].Object.sus_type[ll_row]       = dw_temp.Object.sus_type[ll_row]
	tab_1.idw_tabpage[1].Object.validkey_new[ll_row]   = dw_temp.Object.validkey_new[ll_row]
	tab_1.idw_tabpage[1].Object.svc_add_type[ll_row]   = dw_temp.Object.svc_add_type[ll_row]
	tab_1.idw_tabpage[1].Object.priceplan_new[ll_row]  = dw_temp.Object.priceplan_new[ll_row]
	tab_1.idw_tabpage[1].Object.modelno_new[ll_row]    = dw_temp.Object.modelno_new[ll_row]
	tab_1.idw_tabpage[1].Object.serialno_new[ll_row]   = dw_temp.Object.serialno_new[ll_row]
	tab_1.idw_tabpage[1].Object.usimno_new[ll_row]     = dw_temp.Object.usimno_new[ll_row]
	tab_1.idw_tabpage[1].Object.contno_new[ll_row]     = dw_temp.Object.contno_new[ll_row]
	tab_1.idw_tabpage[1].Object.reason[ll_row]         = dw_temp.Object.reason[ll_row]
	tab_1.idw_tabpage[1].Object.remark[ll_row]         = dw_temp.Object.remark[ll_row]
	tab_1.idw_tabpage[1].Object.crtdt[ll_row]          = today()
	tab_1.idw_tabpage[1].Object.updt[ll_row]           = today()
	tab_1.idw_tabpage[1].Object.crt_user[ll_row]       = ls_operator
	tab_1.idw_tabpage[1].Object.updt_user[ll_row]      = ls_operator
NEXT

//tab1.dw1.update
li_rtn = tab_1.idw_tabpage[1].update()

If li_rtn = 1 Then
	
	//Insert MOBILE_COMPARE_LOG
	INSERT INTO MOBILE_COMPARE_LOG (
					AGENT_CD,    REQDT,     SEQ,          FILENM,       FILENM_DESC
				 , REQCNT
				 , CRTDT,       UPDT,      CRT_USER,     UPDT_USER,    PGM_ID) 
		  VALUES (
		         :ls_partner, :ld_reqdt, :ll_maxseq,   :is_fileName, :ls_file_desc
				 , :ll_rtn_cnt
				 , SYSDATE,     SYSDATE,   :ls_operator, :ls_operator, :gs_pgm_id[gi_open_win_no]
					)
					;
	
	If SQLCA.SQLCODE < 0 Then
		ROLLBACK;
		f_msg_sql_err("확인", " INSERT Error(MODEL_PRICE_UPLOG)")
		RETURN lb_return
	End If	
	
	COMMIT;
Else
	Rollback;
	Messagebox("실패", "자료가 업로드 되지 않았습니다. 중복자료가 있는지 체크하세요.")
	RETURN lb_return
End If

//SUCCESS
tab_1.idw_tabpage[1].SetRedraw(True)
Messagebox("완료", string(ll_rtn_cnt) + "개의 자료가 업로드 되었습니다.")

//RESET
Trigger Event ue_reset()

//조회
dw_cond.Object.reqdt[1]    = ld_reqdt
dw_cond.Object.svc_type[1] = ls_svc_type
Trigger Event ue_ok()

//RETURN
RETURN 0
end event

event ue_find;string pathName, fileName , ls_save_file , ls_svccod
long ll_xls
	
int value, li_rtn
string ls_win_path 
ls_win_path = space(250)

GetCurrentDirectoryA(250, ls_win_path)		
value = GetFileOpenName("Select File", pathName, fileName, "XLS", &
"Excel Files (*.xlsx),*.xlsx," + "Excel Files (*.xls),*.xls," + "All Files(*.*),*.*")
//"Excel Files (*.xls),*.xls," + "Excel Files (*.xlsx),*.xlsx," + "All Files(*.*),*.xlsx")
		
IF value = 1 THEN
	sle_filename.text = pathName
END IF

OleObject oleExcel 

oleExcel = Create OleObject 
li_rtn = oleExcel.connecttonewobject("excel.application") 

IF value = 1 THEN
	IF li_rtn = 0 THEN
		oleExcel.WorkBooks.Open(pathName) 
	ELSE
		Messagebox("Information", "Error Occured!!") 
		Destroy oleExcel 
		Return false
	END IF
ELSE
	Destroy oleExcel 
	Return false
END IF
		

oleExcel.Application.Visible = False 

ll_xls = pos(pathName, 'xls')
ls_save_file = mid(pathName, 1, ll_xls -2) + string(now(),'hhmmss') + '.txt'
is_file = ls_save_file
is_fileName = fileName

				
oleExcel.Application.workbooks(1).SaveAs(ls_save_file,-4158) 
oleExcel.Application.workbooks(1).Saved = True
oleExcel.Application.Quit 
oleExcel.DisConnectObject() 
Destroy oleExcel

//버튼 그림파일 경로 되돌려주기
SetCurrentDirectoryA( ls_win_path )

//파일읽기 처리
//Trigger Event ue_fileread()
//p_fileread.TriggerEvent("clicked")
p_fileread.TriggerEvent("ue_enable")

return true
end event

event ue_process;String ls_partner, ls_operator, ls_agent_cd, ls_errmsg
Date   ld_reqdt
Long   ll_selected_row, ll_seq, ll_return, ll_rc
Int    vi_exists, li_return

//Row Check
IF dw_master.RowCount() < 1 THEN Return false

//dw_master Row
ll_selected_row = dw_master.GetSelectedRow(0)

//Condition
ls_partner  = dw_cond.Object.partner[1]
ls_operator = dw_cond.Object.operator[1]

If f_nvl_chk(dw_cond, 'partner', 1, ls_partner, '')   = False Then Return false
If f_nvl_chk(dw_cond, 'operator', 1, ls_operator, '') = False Then Return false


//기등록여부 체크
SELECT COUNT(*) INTO :vi_exists
  FROM MOBILE_UBS_COMPARE
 WHERE 1=1
   AND AGENT_CD = :is_partner
	AND REQDT    = :ld_reqdt
	AND SEQ      = :ll_seq
	;
	
IF SQLCA.SQLCODE <> 0 Then
	f_msg_sql_err(SQLCA.SQLERRTEXT, "Select MOBILE_UBS_COMPARE Fail. (AGENT_CD=" + is_partner + ", REQDT=" +String(ld_reqdt)+", SEQ=" +String(ll_seq)+ ")")
	Return false
END IF	
	
If vi_exists > 0 Then
	//Question
	li_return = Messagebox(Title, "비교자료를  재생성하시겠습니까?", none!, YesNoCancel!, 3)	
Else
	//Question
	li_return = Messagebox(Title, "비교자료를  생성하시겠습니까?", none!, YesNoCancel!, 3)
End If
	
//Yes 처리
If li_return = 1 Then
	SetPointer(HourGlass!)
	
	//Get Mst Info
	ls_agent_cd = dw_master.Object.agent_cd[ll_selected_row]
	ld_reqdt    = Date(dw_master.Object.reqdt[ll_selected_row])
	ll_seq      = dw_master.Object.seq[ll_selected_row]
	
	
	//Procedure Call
	ll_return 		= -1
	ls_errmsg 		= space(800)
	
	//처리부분...
	SQLCA.B1W_PRC_DATA_COMPARE_MAIN(ls_agent_cd, ld_reqdt, ll_seq, ls_operator, ll_return, ls_errmsg)
	ll_rc = ll_return
	If ll_rc < 0 Then
		//dw_detail.SetItemStatus(1, 0, Primary!, NotModified!)
		MessageBox(This.Title, ls_errmsg)
		Return false
	End If	
	
	SetPointer(Arrow!)
	
	//성공처리
	f_msg_info(3000,This.Title,"Save")
	
	//재조회
	tab_1.Trigger Event SelectionChanged(3, 3)	
End If


//No Error
RETURN true
end event

event ue_fileread2;
//Long		ll_cnt = 0, ll_add_row, ll_row, ll_rtn_cnt, ll_filerow = 0	
String   ls_operator, ls_partner, ls_svc_type, ls_filename, ls_file_desc
Date     ld_reqdt
Long		ll_maxseq, ll_filerow, ll_rtn_cnt, ll_cnt, ll_row
Int		li_rtn
Boolean  lb_return = false


//필수값 Check
dw_cond.AcceptText()

ls_operator = dw_cond.object.operator[1]
ls_partner  = dw_cond.object.partner[1]

ld_reqdt    = dw_cond.object.reqdt[1]
If f_nvl_chk(dw_cond, 'reqdt', 1, String(ld_reqdt), '') = False Then Return lb_return

//ls_svc_type = dw_cond.object.svc_type[1]
//If f_nvl_chk(dw_cond, 'svc_type', 1, ls_svc_type, '') = False Then Return lb_return

ls_filename = sle_filename.text 
IF is_file = "" or IsNull(is_file) THEN
	f_msg_info(200, "", "파일명을 입력하세요.")
	sle_filename.SetFocus()
	RETURN lb_return
END IF

ls_file_desc = trim(mle_filedesc.text)

IF ls_file_desc = '' THEN
	f_msg_info(200, "", "파일설명을 입력하세요.")
	mle_filedesc.SetFocus()
	RETURN lb_return
END IF


//파일 임포트
dw_temp.reset()
ll_rtn_cnt = dw_temp.ImportFile(is_file,3)

//임포트 에러 메세지
Choose case ll_rtn_cnt
	case  0
		Messagebox("Information",'End of file; too many rows ') 
		RETURN lb_return
	CASE -1   
		MessageBox('Information', 'No rows') 
		RETURN lb_return
	CASE -2   
		MessageBox('Information', 'Empty file') 
		RETURN lb_return
	CASE -3   
		MessageBox('Information', 'Invalid argument') 
		RETURN lb_return
	CASE -4   
		MessageBox('Information', 'Invalid input') 
		RETURN lb_return
	CASE -5   
		MessageBox('Information', 'Could not open the file') 
		RETURN lb_return
	CASE -6   
		MessageBox('Information', 'Could not close the file') 
		RETURN lb_return
	CASE -7   
		MessageBox('Information', 'Error reading the text') 
		RETURN lb_return
	CASE -8   
		MessageBox('Information', 'Not a TXT file') 
		RETURN lb_return
	CASE -9   
		MessageBox('Information', 'The user canceled the import') 
		RETURN lb_return
	CASE ELSE
END CHOOSE 



//원본자료로 생성
SELECT NVL(MAX(SEQ), 0) + 1 INTO :ll_maxseq
  FROM MOBILE_COMPARE_LOG
 WHERE 1=1
   AND AGENT_CD = :gs_shopid
	AND REQDT    = :ld_reqdt
	;
	
If SQLCA.SQLCode < 0 Then
	f_msg_sql_err(SQLCA.SQLERRTEXT, "GET MAX SEQ Fail. ([MOBILE_COMPARE_LOG]AGENT_CD=" +gs_shopid+ ", REQDT=" +String(ld_reqdt)+ ", SVC_TYPE=" +ls_svc_type+ ")")
	Return lb_return
End If	


//초기화
ll_filerow = dw_temp.rowcount()
tab_1.idw_tabpage[1].reset()
ll_cnt = 0
			
FOR ll_row = 1 to ll_filerow
	
	//Data Check
	If ld_reqdt <> dw_temp.Object.reqdt[ll_row] Then
		ROLLBACK;
		f_msg_info(200, "", "비교일자와 데이터의 신청일자가 다릅니다!. (" + String(ll_row, '#,##0') + "Line, "+String(dw_temp.Object.reqdt[ll_row], 'YYYY-MM-DD')+")")
		RETURN lb_return		
	End If
	
	//Set Count
	ll_cnt += 1
	
	//Insert Row
	tab_1.idw_tabpage[1].InsertRow(ll_row)
	
	//Set Row
	tab_1.idw_tabpage[1].Object.agent_cd[ll_row]       = ls_partner
	tab_1.idw_tabpage[1].Object.reqdt[ll_row]          = dw_temp.Object.reqdt[ll_row]
	tab_1.idw_tabpage[1].Object.seq[ll_row]            = ll_maxseq
	tab_1.idw_tabpage[1].Object.svc_type[ll_row]       = ls_svc_type
	tab_1.idw_tabpage[1].Object.shop[ll_row]           = dw_temp.Object.shop[ll_row]
	tab_1.idw_tabpage[1].Object.operator[ll_row]       = dw_temp.Object.operator[ll_row]
	tab_1.idw_tabpage[1].Object.validkey[ll_row]       = dw_temp.Object.validkey[ll_row]
	tab_1.idw_tabpage[1].Object.priceplan[ll_row]      = dw_temp.Object.priceplan[ll_row]
	tab_1.idw_tabpage[1].Object.sms_yn[ll_row]         = dw_temp.Object.sms_yn[ll_row]
	tab_1.idw_tabpage[1].Object.modelno[ll_row]        = dw_temp.Object.modelno[ll_row]
	tab_1.idw_tabpage[1].Object.serialno[ll_row]       = dw_temp.Object.serialno[ll_row]
	tab_1.idw_tabpage[1].Object.contno[ll_row]         = dw_temp.Object.contno[ll_row]
	tab_1.idw_tabpage[1].Object.usimno[ll_row]         = dw_temp.Object.usimno[ll_row]
	tab_1.idw_tabpage[1].Object.term_amt[ll_row]       = dw_temp.Object.term_amt[ll_row]
	tab_1.idw_tabpage[1].Object.validkey_check[ll_row] = dw_temp.Object.validkey_check[ll_row]
	tab_1.idw_tabpage[1].Object.sus_type[ll_row]       = dw_temp.Object.sus_type[ll_row]
	tab_1.idw_tabpage[1].Object.validkey_new[ll_row]   = dw_temp.Object.validkey_new[ll_row]
	tab_1.idw_tabpage[1].Object.svc_add_type[ll_row]   = dw_temp.Object.svc_add_type[ll_row]
	tab_1.idw_tabpage[1].Object.priceplan_new[ll_row]  = dw_temp.Object.priceplan_new[ll_row]
	tab_1.idw_tabpage[1].Object.modelno_new[ll_row]    = dw_temp.Object.modelno_new[ll_row]
	tab_1.idw_tabpage[1].Object.serialno_new[ll_row]   = dw_temp.Object.serialno_new[ll_row]
	tab_1.idw_tabpage[1].Object.usimno_new[ll_row]     = dw_temp.Object.usimno_new[ll_row]
	tab_1.idw_tabpage[1].Object.contno_new[ll_row]     = dw_temp.Object.contno_new[ll_row]
	tab_1.idw_tabpage[1].Object.reason[ll_row]         = dw_temp.Object.reason[ll_row]
	tab_1.idw_tabpage[1].Object.remark[ll_row]         = dw_temp.Object.remark[ll_row]
	tab_1.idw_tabpage[1].Object.crtdt[ll_row]          = today()
	tab_1.idw_tabpage[1].Object.updt[ll_row]           = today()
	tab_1.idw_tabpage[1].Object.crt_user[ll_row]       = ls_operator
	tab_1.idw_tabpage[1].Object.updt_user[ll_row]      = ls_operator
NEXT

//tab1.dw1.update
li_rtn = tab_1.idw_tabpage[1].update()

If li_rtn = 1 Then
	
	//Insert MOBILE_COMPARE_LOG
	INSERT INTO MOBILE_COMPARE_LOG (
					AGENT_CD,    REQDT,     SEQ,          FILENM,       FILENM_DESC
				 , REQCNT
				 , CRTDT,       UPDT,      CRT_USER,     UPDT_USER,    PGM_ID) 
		  VALUES (
		         :ls_partner, :ld_reqdt, :ll_maxseq,   :is_file,     :ls_file_desc
				 , :ll_rtn_cnt
				 , SYSDATE,     SYSDATE,   :ls_operator, :ls_operator, :gs_pgm_id[gi_open_win_no]
					)
					;
	
	If SQLCA.SQLCODE < 0 Then
		ROLLBACK;
		f_msg_sql_err("확인", " INSERT Error(MODEL_PRICE_UPLOG)")
		RETURN lb_return
	End If	
	
	COMMIT;
Else
	Rollback;
	Messagebox("실패", "자료가 업로드 되지 않았습니다. 중복자료가 있는지 체크하세요.")
	RETURN lb_return
End If

//SUCCESS
Messagebox("완료", string(ll_rtn_cnt) + "개의 자료가 업로드 되었습니다.")

//RESET
Trigger Event ue_reset()

//조회
dw_cond.Object.reqdt[1]    = ld_reqdt
dw_cond.Object.svc_type[1] = ls_svc_type
Trigger Event ue_ok()

//RETURN
RETURN TRUE
end event

event ue_saveas;
Long li_selected
String ls_win_path

GetCurrentDirectoryA(250, ls_win_path)	

li_selected = tab_1.Selectedtab
f_excel_ascii1(tab_1.idw_tabpage[li_selected],'파일명을 입력하세요')

//버튼 그림파일 경로 되돌려주기
SetCurrentDirectoryA( ls_win_path )
end event

public function integer wfi_cut_string (string as_source, string as_cut, ref string as_result[]);//문자열을 특정구분자(as_cut)로 자른다.
Long ll_rc = 1
Int li_index = 0

as_source = Trim(as_source)
If as_source <> '' Then
	Do While(ll_rc <> 0 )
		li_index ++
		ll_rc = Pos(as_source, as_cut)
		If ll_rc <> 0 Then
			as_result[li_index] = Trim(Left(as_source, ll_rc - 1))
		Else
			as_result[li_index] = Trim(as_source)
		End If

		as_source = Mid(as_source, ll_rc + 2)
	Loop
End If

Return li_index
end function

public function integer wf_create_rate_mobile (string as_fromdt, integer ai_seq);
string ls_priceplan, ls_sale_modelcd, ls_itemcod, ls_pitemcod, ls_svccod
dec 		ld_ubs_amt, ld_p_total, ld_mth_amt
integer i, li_mon, li_cnt, li_cnt1, li_cnt2, li_cnt3


ls_svccod = dw_cond.object.svccod[1]

//단말모델 설정확인
SELECT COUNT(*) INTO :li_cnt 
FROM SYSCOD2T
WHERE GRCODE = 'ZM100'
  AND REF_CODE1 = :ls_svccod;

IF SQLCA.SQLCODE < 0 THEN
		f_msg_sql_err(Title, "SELECT Error(판매모델명)")
		RETURN -1
ELSEIF li_cnt = 0 THEN //NOT FOUND
		MESSAGEBOX("판매모델설정","설정된 단말모델명이 없습니다. CODE CONTROL1 메뉴의 ZM100 코드에 판매모델명울 설정하세요")
		RETURN -1
END IF

//단말할부개월수 확인
SELECT COUNT(*) INTO :li_cnt1 
FROM SYSCOD2T
WHERE GRCODE = 'ZM102';

IF SQLCA.SQLCODE < 0 THEN
		f_msg_sql_err(Title, "SELECT Error(단말할부개월수)")
		RETURN -1
ELSEIF li_cnt1 = 0 THEN //NOT FOUND
		MESSAGEBOX("단말할부개월수설정","설정된 단말할부개월수가 없습니다. CODE CONTROL1 메뉴의 ZM102 코드에 개월수를 설정하세요")
		RETURN -1
END IF

//단말할부아이템 확인
SELECT COUNT(*) INTO :li_cnt2 
FROM SYSCOD2T
WHERE GRCODE = 'ZM101'
  AND REF_CODE1 = :ls_svccod;
	
IF SQLCA.SQLCODE < 0 THEN
		f_msg_sql_err(Title, "SELECT Error(단말할부아이템)")
		RETURN -1
ELSEIF li_cnt2 = 0 THEN //NOT FOUND
		MESSAGEBOX("단말할부아이템설정","설정된 단말할부아이템이 없습니다. CODE CONTROL1 메뉴의 ZM101 코드에 단말할부아이템을 설정하세요")
		RETURN -1
END IF

//위약아이템 확인
SELECT COUNT(*) INTO :li_cnt3 
FROM SYSCOD2T
WHERE GRCODE = 'ZM202'
  AND REF_CODE1 = :ls_svccod;

IF SQLCA.SQLCODE < 0 THEN
		f_msg_sql_err(Title, "SELECT Error(위약아이템)")
		RETURN -1
ELSEIF li_cnt3 = 0 THEN //NOT FOUND
		MESSAGEBOX("위약아이템설정","설정된 위약아이템이 없습니다. CODE CONTROL1 메뉴의 ZM202 코드에 위약아이템을 설정하세요")
		RETURN -1
END IF



DECLARE CUR_PRICEPLAN_UPLOAD  CURSOR FOR

			SELECT  	SVCCOD,
						(SELECT CODE FROM SYSCOD2T WHERE GRCODE= 'ZM101' AND REF_CODE1 = B.REF_CODE1) AS ITEMCOD, /*단말할부아이템*/
						(SELECT CODE FROM SYSCOD2T WHERE GRCODE = 'ZM202'  AND REF_CODE1 = :ls_svccod) AS P_ITEMCOD, /*위약아이템*/
						PRICEPLAN,  
						SALE_MODELCD, 
						UBS_AMT, 
						NVL(SUB_AMT1,0) + NVL(SUB_AMT2, 0),
						TO_NUMBER(C.CODE) AS MON,
						ROUND(UBS_AMT/ TO_NUMBER(C.CODE),0)
        FROM MODEL_PRICEPLAN_UPLOAD A, SYSCOD2T B, SYSCOD2T C
        WHERE A.SALE_MODELCD = B.CODE
		  		AND A.SVCCOD = B.REF_CODE1
            AND B.GRCODE = 'ZM100'  /*기준단말모델*/
				AND C.GRCODE = 'ZM102'  /*단말할부 개월수*/
				AND A.SVCCOD = :ls_svccod
            AND FROMDT = :AS_FROMDT
		  AND SEQ = :AI_SEQ;
          
		  
OPEN CUR_PRICEPLAN_UPLOAD;

		DO WHILE SQLCA.SQLCODE = 0
			FETCH CUR_PRICEPLAN_UPLOAD INTO :ls_svccod, :ls_itemcod, :ls_pitemcod, :ls_priceplan, :ls_sale_modelcd, 
			      :ld_ubs_amt, :ld_p_total, :li_mon, :ld_mth_amt;
			
			IF sqlca.sqlcode <> 0 THEN
					EXIT;
			END IF
			  	  
				  INSERT INTO PRICEPLAN_RATE_MOBILE
				  VALUES
				  (:ls_svccod, :ls_priceplan, :ls_sale_modelcd, :li_mon , :as_fromdt, null, :ls_itemcod, :ld_mth_amt,
				   :ld_p_total, :ls_pitemcod, sysdate,null,  :gs_user_id, null, null);
				  
				  IF SQLCA.SQLCODE < 0 THEN
							f_msg_sql_err(Title, "Insert Error(PRICEPLAN_RATE_MOBILE)")
							ROLLBACK;
							RETURN -1
				  END IF
									  
		LOOP
		
CLOSE CUR_PRICEPLAN_UPLOAD;

COMMIT;

return 0
end function

on b1w_prc_data_compare_mobile.create
int iCurrent
call super::create
this.st_1=create st_1
this.st_2=create st_2
this.sle_filename=create sle_filename
this.mle_filedesc=create mle_filedesc
this.dw_temp=create dw_temp
this.p_find=create p_find
this.p_fileread=create p_fileread
this.cb_create=create cb_create
this.p_saveas=create p_saveas
this.gb_file=create gb_file
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_1
this.Control[iCurrent+2]=this.st_2
this.Control[iCurrent+3]=this.sle_filename
this.Control[iCurrent+4]=this.mle_filedesc
this.Control[iCurrent+5]=this.dw_temp
this.Control[iCurrent+6]=this.p_find
this.Control[iCurrent+7]=this.p_fileread
this.Control[iCurrent+8]=this.cb_create
this.Control[iCurrent+9]=this.p_saveas
this.Control[iCurrent+10]=this.gb_file
end on

on b1w_prc_data_compare_mobile.destroy
call super::destroy
destroy(this.st_1)
destroy(this.st_2)
destroy(this.sle_filename)
destroy(this.mle_filedesc)
destroy(this.dw_temp)
destroy(this.p_find)
destroy(this.p_fileread)
destroy(this.cb_create)
destroy(this.p_saveas)
destroy(this.gb_file)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	: b1w_prc_data_compare_mobile
	Desc.	: 모바일 개통처 비교레포트
	Ver.	: 1.0
	Date	: 2015.03.26
	Programer : LYS
------------------------------------------------------------------------*/
string ls_today, ls_partner

//손모양 비활성화
tab_1.idw_tabpage[1].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[2].SetRowFocusIndicator(Off!)
tab_1.idw_tabpage[3].SetRowFocusIndicator(Off!)

//개통처
SELECT EMP_GROUP INTO :ls_partner
  FROM SYSUSR1T
 WHERE 1=1
	AND EMP_NO    = :gs_user_id
//	AND EMP_GROUP IN (
//						  SELECT CODE
//							 FROM SYSCOD2T
//							WHERE 1=1
//							  AND GRCODE = 'ZM300'
//						  )
	;
	

	
IF SQLCA.SQLCODE <> 0 Then
	f_msg_sql_err(SQLCA.SQLERRTEXT, "Select SYSUSR1T Fail. (EMP_NO=" + gs_user_id + ")")
	Return -1
END IF

is_partner = ls_partner


//tab_1.idw_tabpage[1].SetRowFocusIndicator(Off!)
//tab_1.idw_tabpage[2].SetRowFocusIndicator(Off!)

dw_cond.object.reqdt[1]   = today()
dw_cond.object.partner[1] = is_partner

//버튼 조정
p_fileread.TriggerEvent("ue_disable")
p_saveas.TriggerEvent("ue_disable")

end event

event ue_ok;//dw_master 조회
String ls_where, ls_reqdt, ls_svc_type
Long ll_row

dw_cond.AcceptText()

//Null Check
ls_reqdt    = String(dw_cond.object.reqdt[1], 'yyyymmdd')
If f_nvl_chk(dw_cond, 'reqdt', 1, ls_reqdt, '') = False Then Return

ls_svc_type = dw_cond.object.svc_type[1]
If IsNull(ls_svc_type) Then ls_svc_type = ""

//Set where
ls_where = ""
//If gs_user_id <> "" Then
//	If ls_where <> "" Then ls_where += " AND "
//	ls_where += "agent_cd = '" + gs_shopid + "' "
//End If

If ls_reqdt <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "reqdt = to_date('" + ls_reqdt + "', 'yyyymmdd') "
End If

//If ls_svc_type <> "" Then
//	If ls_where <> "" Then ls_where += " AND "
//	ls_where += "svc_type = '" + ls_svc_type + "' "
//End If

//Retrieve
dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()

If ll_row = 0 Then 
	f_msg_info(1000, Title, "")

ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
Else
	//첫번째 row로 간다.
	dw_master.ScrollToRow(1)
	dw_master.selectrow(0, false)
	dw_master.selectrow(1, true)
	dw_master.SetFocus()	
	
	//검색을 찾으면 Tab를 활성화 시킨다.
	tab_1.Trigger Event SelectionChanged(1, 1)
	tab_1.Enabled = True
	
End If

//버튼처리
//p_insert.TriggerEvent("ue_disable")
//p_delete.TriggerEvent("ue_disable")
//p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")
cb_create.Enabled = false
end event

event ue_reset;call super::ue_reset;//dw_cond
dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()
dw_cond.SetColumn("reqdt")
dw_cond.Object.partner[1]    = is_partner
dw_cond.Object.operator[1]   = gs_user_id
dw_cond.Object.operatornm[1] = gs_user_id
dw_cond.Object.reqdt[1]      = today()
dw_cond.Object.svc_type[1]   = ''  

//Tab1
tab_1.SelectedTab = 1
//p_delete.TriggerEvent("ue_disable")
//p_save.TriggerEvent("ue_disable")

//file read
p_find.TriggerEvent("ue_enable")
p_fileread.TriggerEvent("ue_disable")
sle_filename.text = ''
mle_filedesc.text = ''

//dw_temp
dw_temp.Reset()

//reset
Return 0 
end event

event resize;call super::resize;//위치추가
If sizetype = 1 Then Return

p_saveas.X = (p_reset.X + 313)
p_saveas.Y = p_reset.Y

cb_create.X = (p_reset.X + 700)
cb_create.Y = p_reset.Y
end event

type dw_cond from w_a_reg_m_tm2`dw_cond within b1w_prc_data_compare_mobile
integer x = 46
integer y = 72
integer width = 2583
integer height = 196
string dataobject = "b1dw_cnd_data_compare_mobile"
boolean border = true
boolean livescroll = false
end type

event dw_cond::ue_init;//svc_type
f_dddw_list2(This, 'svc_type', 'ZM700')
end event

type p_ok from w_a_reg_m_tm2`p_ok within b1w_prc_data_compare_mobile
integer x = 2821
end type

type p_close from w_a_reg_m_tm2`p_close within b1w_prc_data_compare_mobile
integer x = 2821
integer y = 176
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_tm2`gb_cond within b1w_prc_data_compare_mobile
integer x = 3150
integer width = 1769
integer height = 300
integer taborder = 0
end type

type dw_master from w_a_reg_m_tm2`dw_master within b1w_prc_data_compare_mobile
integer y = 328
integer width = 3237
integer height = 696
integer taborder = 50
string dataobject = "b1dw_inq_mobile_compare_log"
end type

event dw_master::clicked;call super::clicked;//If row < 1 Then Return
end event

event dw_master::ue_init;call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.crtdt_t
uf_init( ldwo_sort , "D", RGB(0,0,128))
end event

type p_insert from w_a_reg_m_tm2`p_insert within b1w_prc_data_compare_mobile
boolean visible = false
integer y = 2300
end type

type p_delete from w_a_reg_m_tm2`p_delete within b1w_prc_data_compare_mobile
boolean visible = false
integer y = 2300
end type

type p_save from w_a_reg_m_tm2`p_save within b1w_prc_data_compare_mobile
boolean visible = false
integer x = 622
integer y = 2300
end type

type p_reset from w_a_reg_m_tm2`p_reset within b1w_prc_data_compare_mobile
integer x = 37
integer y = 2300
end type

type tab_1 from w_a_reg_m_tm2`tab_1 within b1w_prc_data_compare_mobile
integer x = 32
integer y = 1048
integer width = 3237
integer height = 1212
integer taborder = 60
integer weight = 700
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
end type

event tab_1::ue_init;call super::ue_init;//Tab 초기화
ii_enable_max_tab = 3 //사용할 Tab Page의 갯수 (15 이하)

is_tab_title[1] = "개통처자료"
is_tab_title[2] = "UBS자료"
is_tab_title[3] = "비교자료"

is_dwobject[1] = "b1dw_inq_mobile_data_compare"
is_dwobject[2] = "b1dw_inq_mobile_ubs_compare"
is_dwobject[3] = "b1dw_inq_mobile_compare_result"

end event

event tab_1::ue_tabpage_retrieve;
String ls_where, ls_agent_code, ls_reqdt, ls_seq, ls_svc_type
long ll_row

IF al_master_row = 0 THEN RETURN -1		//해당 정보 없음

//tab_1.idw_tabpage[ai_select_tabpage].accepttext()
ls_agent_code = dw_master.Object.agent_cd[al_master_row]
ls_reqdt      = String(dw_master.Object.reqdt[al_master_row], 'yyyymmdd')
ls_seq        = String(dw_master.Object.seq[al_master_row])
ls_svc_type   = fs_snvl(dw_cond.Object.svc_type[1],"")


//tab1, 2, 3의 조건절이 다 똑같다.
ls_where = ""
If ls_where <> "" Then ls_where += " AND "
ls_where += "agent_cd = '" + ls_agent_code + "' AND "
ls_where += "reqdt = to_date('" + ls_reqdt + "', 'yyyymmdd') AND "
ls_where += "seq = to_number('" + ls_seq + "') "

If ls_svc_type <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "svc_type = '" + ls_svc_type + "' "
End If

idw_tabpage[ai_select_tabpage].is_where = ls_where		
ll_row = idw_tabpage[ai_select_tabpage].Retrieve()	
IF ll_row < 0 THEN
	p_saveas.TriggerEvent("ue_disable")
	f_msg_usr_err(2100, Parent.Title, "Retrieve()")
	RETURN -1
Else
	p_saveas.TriggerEvent("ue_enable")
END IF


RETURN 0 
		

		
end event

event tab_1::selectionchanged;call super::selectionchanged;int li_rtn, li_seq, li_return
long ll_master_row
string ls_fromdt



CHOOSE CASE newindex
	CASE 1
		//버튼처리
		//p_insert.TriggerEvent("ue_disable")
		//p_delete.TriggerEvent("ue_disable")
		//p_save.TriggerEvent("ue_disable")
		p_reset.TriggerEvent("ue_enable")
		cb_create.enabled = true
		
	CASE 2
		//버튼처리
		p_reset.TriggerEvent("ue_enable")
		cb_create.enabled = false	
		
	CASE 3
		//버튼처리
		p_reset.TriggerEvent("ue_enable")
		cb_create.enabled = false		
END CHOOSE


end event

event tab_1::ue_dw_clicked;If al_row  <> 0 then

   tab_1.idw_tabpage[ai_tabpage].SelectRow(0, FALSE )
	tab_1.idw_tabpage[ai_tabpage].SelectRow( al_row , TRUE )
End If

return 0
end event

type st_horizontal from w_a_reg_m_tm2`st_horizontal within b1w_prc_data_compare_mobile
integer y = 1024
end type

type st_1 from statictext within b1w_prc_data_compare_mobile
integer x = 3173
integer y = 92
integer width = 133
integer height = 48
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 33554432
long backcolor = 29478337
string text = "파일"
boolean focusrectangle = false
end type

type st_2 from statictext within b1w_prc_data_compare_mobile
integer x = 3173
integer y = 200
integer width = 155
integer height = 76
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 33554432
long backcolor = 29478337
string text = "설명"
boolean focusrectangle = false
end type

type sle_filename from singlelineedit within b1w_prc_data_compare_mobile
integer x = 3291
integer y = 72
integer width = 1029
integer height = 84
integer taborder = 20
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 1090519039
long backcolor = 25793388
end type

type mle_filedesc from multilineedit within b1w_prc_data_compare_mobile
integer x = 3291
integer y = 180
integer width = 1605
integer height = 80
integer taborder = 30
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 1090519039
long backcolor = 25793388
integer limit = 100
end type

type dw_temp from u_d_sgl_sel within b1w_prc_data_compare_mobile
integer x = 3296
integer y = 432
integer width = 704
integer height = 532
integer taborder = 70
boolean bringtotop = true
string dataobject = "b1dw_inq_mobile_data_compare_tmp"
boolean hsplitscroll = true
borderstyle borderstyle = stylebox!
end type

event constructor;call super::constructor;this.visible = false
end event

type p_find from u_p_find within b1w_prc_data_compare_mobile
integer x = 4329
integer y = 68
boolean bringtotop = true
end type

type p_fileread from u_p_fileread within b1w_prc_data_compare_mobile
event type boolean ue_fileread ( )
integer x = 4622
integer y = 68
boolean bringtotop = true
boolean originalsize = false
end type

event clicked;//Override
Int li_rtn
li_rtn= Parent.Trigger Event ue_fileread()
If li_rtn < 0 Then
	tab_1.idw_tabpage[1].SetRedraw(True)
	tab_1.idw_tabpage[1].reset()	
End If

//txt파일 삭제
If li_rtn < 1 and FileExists(is_file) Then
	FileDelete(is_file)
	sle_filename.text = ""
End If
		

end event

type cb_create from commandbutton within b1w_prc_data_compare_mobile
integer x = 727
integer y = 2300
integer width = 485
integer height = 96
integer taborder = 70
boolean bringtotop = true
integer textsize = -8
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "비교자료 생성"
end type

event clicked;
//재처리 
Parent.TriggerEvent('ue_process')
end event

type p_saveas from u_p_saveas within b1w_prc_data_compare_mobile
event ue_saveas ( )
integer x = 352
integer y = 2300
boolean bringtotop = true
boolean originalsize = false
end type

type gb_file from gb_cond within b1w_prc_data_compare_mobile
integer x = 32
integer width = 3118
end type

