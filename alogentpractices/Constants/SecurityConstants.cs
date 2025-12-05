using System;

namespace alogentpractices.Constants
{
    //Flags for the various levels of Record and Document Security
    public static class SecurityConstants
    {
        public const string REC_READ = "allowRead";
        public const string REC_ADD = "allowAdd";
        public const string REC_EDIT = "allowEdit";
        public const string REC_DELETE = "allowDelete";
        public const string DOC_READ = "allowDocRead";
        public const string DOC_EDIT = "allowDocEdit";
        public const string DOC_ADD = "allowDocAdd";
        public const string DOC_DELETE = "allowDocDelete";
        public const string DOC_SCAN = "allowDocScan";
        public const string DOC_UPLOAD = "allowDocUpload";
        public const string DOC_MOVECOPY = "allowDocMoveCopy";
        public const string DOC_SCAN_DELETE = "allowDocScanDelete";
        public const string IS_ADMIN = "isAdmin";

        //This is used for bitwise checks of security and should be used over the above flags when possible
        public const int SEC_NONE = 0;
        public const int SEC_READ = 1 << 0;
        public const int SEC_EDIT = 1 << 1;          
        public const int SEC_ADD = 1 << 2;          
        public const int SEC_DELETE = 1 << 3;       
        public const int SEC_DOC_READ = 1 << 4;     
        public const int SEC_DOC_EDIT = 1 << 5;  
        public const int SEC_DOC_ADD = 1 << 6;
        public const int SEC_DOC_DELETE = 1 << 7;   
        public const int SEC_DOC_SCAN = 1 << 8;  
        public const int SEC_DOC_SCAN_DELETE = 1 << 9;
        public const int SEC_DOC_UPLOAD = 1 << 10;  
        public const int SEC_DOC_MOVECOPY = 1 << 11;
        public const int SEC_ADMIN = 1 << 12;
    }
}
