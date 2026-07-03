#define __FBS_PLUG_CDTOR_BI__

'' Copyright 2023 by Jeff Marshall
''   coder[at]execulink.com

'' building shared library

#define FBS_MODULE_CDTOR_SCOPE private 
#define FBS_MODULE_REGISTER_CDTOR
#define FBS_MODULE_CTOR constructor
#define FBS_MODULE_DTOR destructor


#define FBS_GLOBAL_CTOR constructor
#define FBS_GLOBAL_DTOR destructor
