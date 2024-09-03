/// OpenAPI Client Code Generation
// - this unit is a part of the Open Source Synopse mORMot framework 2,
// licensed under a MPL/GPL/LGPL three license - see LICENSE.md
unit mormot.net.openapi;

{
  *****************************************************************************

  OpenAPI Language-agnostic Interface to HTTP APIs
  - OpenAPI Document Wrappers
  - FPC/Delphi Pascal Client Code Generation

  *****************************************************************************
}

interface

{$I ..\mormot.defines.inc}

uses
  sysutils,
  classes,
  mormot.core.base,
  mormot.core.os,
  mormot.core.unicode,
  mormot.core.text,
  mormot.core.buffers,
  mormot.core.datetime,
  mormot.core.data, // for TRawUtf8List
  mormot.core.variants,
  mormot.rest.core;


{ ************************************ OpenAPI Document Wrappers }

type
  /// exception class raised by this Unit
  EOpenApi = class(ESynException);

  TOpenApiParser = class; // forward declaration

  /// define the Swagger (oav2) or OpenAPI 3.x (oav3) schema
  TOpenApiVersion = (
    oavUnknown,
    oav2,
    oav3);

  /// define the native built-in pascal types
  TOpenApiBuiltInType = (
    obtVariant,
    obtInteger,
    obtInt64,
    obtBoolean,
    obtSingle,
    obtDouble,
    obtDate,
    obtDateTime,
    obtGuid,
    obtRawUtf8,
    obtSpiUtf8,
    obtRawByteString);

  /// pointer wrapper to TDocVariantData / variant content of an OpenAPI Schema
  POpenApiSchema = ^TOpenApiSchema;
  /// a dynamic array of pointers wrapper to OpenAPI Schema definition(s)
  POpenApiSchemaDynArray = array of POpenApiSchema;
  /// high-level OpenAPI Schema wrapper to TDocVariantData / variant content
  {$ifdef USERECORDWITHMETHODS}
  TOpenApiSchema = record
  {$else}
  TOpenApiSchema = object
  {$endif USERECORDWITHMETHODS}
  private
    function GetPropertyByName(const aName: RawUtf8): POpenApiSchema;
  public
    /// transtype the POpenApiSchema pointer into a TDocVariantData content
    Data: TDocVariantData;
    // access to the OpenAPI Schema information
    function _Type: RawUtf8;
    function _Format: RawUtf8;
    function Required: PDocVariantData;
    function Enum: PDocVariantData;
    function Nullable: boolean;
    function Description: RawUtf8;
    function ExampleAsText: RawUtf8;
    function PatternAsText: RawUtf8;
    function Reference: RawUtf8;
    function AllOf: POpenApiSchemaDynArray;
    function Items: POpenApiSchema;
    function ItemsOrNil: POpenApiSchema;
    function Properties: PDocVariantData;
    property _Property[const aName: RawUtf8]: POpenApiSchema
      read GetPropertyByName;
    // high-level OpenAPI Schema Helpers
    function IsArray: boolean;
    function IsObject: boolean;
    function IsNamedEnum: boolean;
    function BuiltinType: TOpenApiBuiltInType;
    function HasDescription: boolean;
    function HasItems: boolean;
    function HasExample: boolean;
    function HasPattern: boolean;
  end;

  /// pointer wrapper to TDocVariantData / variant content of an OpenAPI Response
  POpenApiResponse = ^TOpenApiResponse;
  /// high-level OpenAPI Schema wrapper to TDocVariantData / variant content
  {$ifdef USERECORDWITHMETHODS}
  TOpenApiResponse = record
  {$else}
  TOpenApiResponse = object
  {$endif USERECORDWITHMETHODS}
  public
    /// transtype the POpenApiResponse pointer into a TDocVariantData content
    Data: TDocVariantData;
    // access to the OpenAPI Response information
    function Description: RawUtf8;
    function Schema(Parser: TOpenApiParser): POpenApiSchema;
  end;


  /// pointer wrapper to TDocVariantData / variant content of an OpenAPI RequestBody
  // - share the very same fields as TOpenApiResponse
  POpenApiRequestBody = {$ifdef USERECORDWITHMETHODS} type {$endif}POpenApiResponse;

  /// pointer wrapper to TDocVariantData / variant content of an OpenAPI Parameter
  POpenApiParameter = ^TOpenApiParameter;
  /// high-level OpenAPI Parameter wrapper to TDocVariantData / variant content
  {$ifdef USERECORDWITHMETHODS}
  TOpenApiParameter = record
  {$else}
  TOpenApiParameter = object
  {$endif USERECORDWITHMETHODS}
  public
    /// transtype the POpenApiParameter pointer into a TDocVariantData content
    Data: TDocVariantData;
    // access to the OpenAPI Parameter information
    function Name: RawUtf8;
    function Description: RawUtf8;
    function AsPascalName: RawUtf8;
    function _In: RawUtf8;
    function AllowEmptyValues: boolean;
    function Default: PVariant;
    /// true if Default or not Required
    function HasDefaultValue: boolean;
    function Required: boolean;
    function Schema(Parser: TOpenApiParser): POpenApiSchema;
  end;
  /// a dynamic array of pointers wrapper to OpenAPI Parameter(s)
  POpenApiParameterDynArray = array of POpenApiParameter;

  /// pointer wrapper to TDocVariantData / variant content of an OpenAPI Parameters
  POpenApiParameters = ^TOpenApiParameters;
  /// high-level OpenAPI Parameter wrapper to TDocVariantData / variant content
  {$ifdef USERECORDWITHMETHODS}
  TOpenApiParameters = record
  {$else}
  TOpenApiParameters = object
  {$endif USERECORDWITHMETHODS}
  private
    function GetParameterByIndex(aIndex: integer): POpenApiParameter;
      {$ifdef HASINLINE} inline; {$endif}
  public
    /// transtype the POpenApiParameters pointer into a TDocVariantData content
    Data: TDocVariantData;
    // access to the OpenAPI Parameters information
    function Count: integer;
    property Parameter[aIndex: integer]: POpenApiParameter
      read GetParameterByIndex;
  end;

  /// pointer wrapper to TDocVariantData / variant content of an OpenAPI Operation
  POpenApiOperation = ^TOpenApiOperation;
  /// high-level OpenAPI Operation wrapper to TDocVariantData / variant content
  {$ifdef USERECORDWITHMETHODS}
  TOpenApiOperation = record
  {$else}
  TOpenApiOperation = object
  {$endif USERECORDWITHMETHODS}
  private
    function GetResponseForStatusCode(aStatusCode: integer): POpenApiResponse;
  public
    /// transtype the POpenApiOperation pointer into a TDocVariantData content
    Data: TDocVariantData;
    // access to the OpenAPI Operation information
    function Id: RawUtf8;
    function Summary: RawUtf8;
    function Description: RawUtf8;
    function Tags: TRawUtf8DynArray;
    function Deprecated: boolean;
    function Parameters: POpenApiParameters;
    function RequestBody(Parser: TOpenApiParser): POpenApiRequestBody;
    function BodySchema(Parser: TOpenApiParser): POpenApiSchema;
    function Responses: PDocVariantData;
    property Response[aStatusCode: integer]: POpenApiResponse
      read GetResponseForStatusCode;
  end;

  /// pointer wrapper to TDocVariantData / variant content of an OpenAPI Path Item
  POpenApiPathItem = ^TOpenApiPathItem;
  /// high-level OpenAPI Path Item wrapper to TDocVariantData / variant content
  {$ifdef USERECORDWITHMETHODS}
  TOpenApiPathItem = record
  {$else}
  TOpenApiPathItem = object
  {$endif USERECORDWITHMETHODS}
  private
    function GetOperationByMethod(aMethod: TUriMethod): POpenApiOperation;
  public
    /// transtype the POpenApiPathItem pointer into a TDocVariantData content
    Data: TDocVariantData;
    // access to the OpenAPI Path Item information
    function Summary: RawUtf8;
    function Description: RawUtf8;
    function Parameters: POpenApiParameters;
    property Method[aMethod: TUriMethod]: POpenApiOperation
      read GetOperationByMethod;
  end;

  /// pointer wrapper to TDocVariantData / variant content of an OpenAPI Tag
  POpenApiTag = ^TOpenApiTag;
  /// high-level OpenAPI Tag wrapper to TDocVariantData / variant content
  {$ifdef USERECORDWITHMETHODS}
  TOpenApiTag = record
  {$else}
  TOpenApiTag = object
  {$endif USERECORDWITHMETHODS}
  public
    /// transtype the POpenApiTag pointer into a TDocVariantData content
    Data: TDocVariantData;
    // access to the OpenAPI Tag information
    function Description: RawUtf8;
    function Name: RawUtf8;
  end;

  /// pointer wrapper to TDocVariantData / variant content of OpenAPI Specs
  POpenApiSpecs = ^TOpenApiSpecs;
  /// high-level OpenAPI Specs wrapper to TDocVariantData / variant content
  {$ifdef USERECORDWITHMETHODS}
  TOpenApiSpecs = record
  {$else}
  TOpenApiSpecs = object
  {$endif USERECORDWITHMETHODS}
  private
    function GetPathItemByName(const aPath: RawUtf8): POpenApiPathItem;
  public
    /// transtype the POpenApiSpecs pointer into a TDocVariantData content
    Data: TDocVariantData;
    // access to the OpenAPI Specs information
    function Info: PDocVariantData;
    function BasePath: RawUtf8;
    function Paths: PDocVariantData;
    function Tags: PDocVariantData;
    function Version: RawUtf8;
    function VersionEnum: TOpenApiVersion;
    property Path[const aPath: RawUtf8]: POpenApiPathItem
      read GetPathItemByName;
    function Components: PDocVariantData;
    function Schemas(aVersion: TOpenApiVersion): PDocVariantData;
  end;


{ ************************************ FPC/Delphi Pascal Client Code Generation }

  TPascalCustomType = class;

  /// define any Pascal type, as basic type of custom type
  TPascalType = class
  private
    fBuiltinSchema: POpenApiSchema;
    fBuiltinTypeName: RawUtf8;
    fCustomType: TPascalCustomType;
    fBuiltinType: TOpenApiBuiltInType;
    fIsArray, fNoConst: boolean;
    function GetSchema: POpenApiSchema;
    procedure SetArray(AValue: boolean);
  public
    constructor CreateBuiltin(aBuiltinType: TOpenApiBuiltInType;
      aSchema: POpenApiSchema = nil; aIsArray: boolean = false); overload;
    constructor CreateCustom(aCustomType: TPascalCustomType); overload;

    // TODO: Handle RecordArrayType in RTTI definition
    function ToPascalName(AsFinalType: boolean = true;
      NoRecordArrayTypes: boolean = false): RawUtf8;
    function ToFormatUtf8Arg(const VarName: RawUtf8): RawUtf8;
    function ToDefaultParameterValue(aParam: POpenApiParameter;
      Parser: TOpenApiParser): RawUtf8;

    function IsBuiltin: boolean;
    function IsEnum: boolean;
    function IsRecord: boolean;
    property IsArray: boolean
      read fIsArray write SetArray;

    property CustomType: TPascalCustomType
      read fCustomType;
    property Schema: POpenApiSchema
      read GetSchema;
  end;
  TPascalTypeObjArray = array of TPascalType;

  /// define a Pascal property
  TPascalProperty = class
  private
    fType: TPascalType;
    fSchema: POpenApiSchema;
    fName: RawUtf8;
    fPascalName: RawUtf8;
    fTypeOwned: boolean;
  public
    constructor CreateFromSchema(aOwner: TOpenApiParser; const aName: RawUtf8;
      aSchema: POpenApiSchema);
    constructor CreateFrom(another: TPascalProperty);
    destructor Destroy; override;
    property PropType: TPascalType
      read fType;
    property Schema: POpenApiSchema
      read fSchema;
    property Name: RawUtf8
      read fName;
    property PascalName: RawUtf8
      read fPascalName;
  end;

  /// abstract parent class holder for complex types
  TPascalCustomType = class
  private
    fName: RawUtf8;
    fPascalName: RawUtf8;
    fFromRef: RawUtf8;
    fSchema: POpenApiSchema;
    fParser: TOpenApiParser;
    fRequiresArrayDefinition: boolean;
  public
    constructor Create(aOwner: TOpenApiParser; const aPascalName: RawUtf8 = '');
    procedure ToTypeDefinition(W: TTextWriter); virtual; abstract;
    function ToArrayTypeName(AsFinalType: boolean = true): RawUtf8; virtual;
    function ToArrayTypeDefinition: RawUtf8; virtual;
    property Name: RawUtf8
      read fName;
    property PascalName: RawUtf8
      read fPascalName;
    property Schema: POpenApiSchema
      read fSchema;
  end;

  /// define a Pascal data structure, as a packed record with RTTI
  TPascalRecord = class(TPascalCustomType)
  private
    fProperties: TRawUtf8List; // Objects are owned TPascalProperty
    fDependencies: TRawUtf8DynArray;
  public
    constructor Create(aOwner: TOpenApiParser; const SchemaName: RawUtf8;
      Schema: POpenApiSchema = nil);
    destructor Destroy; override;
    procedure CopyProperties(aDest: TRawUtf8List);
    procedure ToTypeDefinition(W: TTextWriter); override;
    function ToRttiTextRepresentation: RawUtf8;
    function ToRttiRegisterDefinitions: RawUtf8;
    property Properties: TRawUtf8List
      read fProperties;
  end;
  TPascalRecordDynArray = array of TPascalRecord;

  /// define a Pascal data array
  TPascalArray = class(TPascalCustomType)

  end;

  /// define a Pascal enumeration type
  TPascalEnum = class(TPascalCustomType)
  private
    fPrefix, fConstTextArrayName: RawUtf8;
    fChoices: TDocVariantData;
  public
    constructor Create(aOwner: TOpenApiParser; const aName: RawUtf8;
      aSchema: POpenApiSchema);
    procedure ToTypeDefinition(W: TTextWriter); override;
    procedure ToRegisterCustom(W: TTextWriter);
    function ToArrayTypeName(AsFinalType: boolean = true): RawUtf8; override;
    function ToConstTextArray: RawUtf8;
    property Prefix: RawUtf8
      read fPrefix;
  end;

  /// define a custom Pascal EJsonClient type (used for 4xx responses)
  TPascalException = class(TPascalCustomType)
  private
    fResponse: POpenApiResponse;
    fErrorType: TPascalType;
    fErrorTypeName: RawUtf8;
    fErrorCode: RawUtf8;
  public
    constructor Create(aOwner: TOpenApiParser; const aCode: RawUtf8;
      aResponse: POpenApiResponse = nil);
    destructor Destroy; override;
    procedure ToTypeDefinition(W: TTextWriter); override;
    procedure Body(W: TTextWriter);
    property Response: POpenApiResponse
      read fResponse;
    property ErrorType: TPascalType
      read fErrorType;
    property ErrorCode: RawUtf8
      read fErrorCode;
  end;

  /// define a Pascal method matching an OpenAPI operation
  TPascalOperation = class
  private
    fParser: TOpenApiParser;
    fPath: RawUtf8;
    fPathItem: POpenApiPathItem;
    fOperation: POpenApiOperation;
    fMethod: TUriMethod;
    fPayloadParameterType: TPascalType;
    fSuccessResponseType: TPascalType;
    fSuccessResponseCode: integer;
    fOnErrorIndex: integer;
    fParameters: POpenApiParameterDynArray;
    fParameterTypes: TPascalTypeObjArray;
  public
    constructor Create(aParser: TOpenApiParser; const aPath: RawUtf8;
      aPathItem: POpenApiPathItem; aOperation: POpenApiOperation; aMethod: TUriMethod);
    destructor Destroy; override;
    procedure ResolveResponseTypes;
    procedure Documentation(W: TTextWriter);
    procedure Declaration(W: TTextWriter; const ClassName: RawUtf8;
      InImplementation: boolean);
    procedure Body(W: TTextWriter; const ClassName, BasePath: RawUtf8);
    function ParameterType(aIndex: integer): TPascalType;
    function FunctionName: RawUtf8;
    property Parameters: POpenApiParameterDynArray
      read fParameters;
  end;
  TPascalOperationDynArray = array of TPascalOperation;

  TPascalOperationsByTag = record
    TagName: RawUtf8;
    Tag: POpenApiTag;
    Operations: TPascalOperationDynArray;
  end;
  TPascalOperationsByTagDynArray = array of TPascalOperationsByTag;

  /// the main OpenAPI parser and pascal code generator class
  TOpenApiParser = class
  private
    fVersion: TOpenApiVersion;
    fSpecs: TOpenApiSpecs;
    fSchemas: PDocVariantData;
    fRecords: TRawUtf8List;    // objects are owned TPascalRecord
    fEnums: TRawUtf8List;      // objects are owned TPascalEnum
    fExceptions: TRawUtf8List; // objects are owned TPascalException
    fErrorHandler: TRawUtf8DynArray;
    fOperations: TPascalOperationDynArray;
    fLineEnd: RawUtf8;
    fLineIndent: RawUtf8;
    fGeneratedBy, fGeneratedByLine: RawUtf8;
    procedure ParseSpecs;
    function GetSchemaByName(const aName: RawUtf8): POpenApiSchema;
    procedure Description(W: TTextWriter; const Described: RawUtf8);
    procedure Comment(W: TTextWriter; const Args: array of const);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    procedure ParseFile(const aJsonFile: TFileName);
    procedure ParseJson(const aJson: RawUtf8);
    procedure Parse(const aSpecs: TDocVariantData);
    procedure ExportToDirectory(const Name: RawUtf8;
      const DirectoryName: TFileName = './'; const UnitPrefix: RawUtf8 = '');
    function ParseRecordDefinition(const aDefinitionName: RawUtf8): TPascalRecord;
    procedure ParsePath(const aPath: RawUtf8);

    function NewPascalTypeFromSchema(aSchema: POpenApiSchema;
      const aSchemaName: RawUtf8 = ''): TPascalType;
    function GetRecord(aRecordName: RawUtf8; NameIsReference: boolean = false): TPascalRecord;
    function GetOrderedRecords: TPascalRecordDynArray;
    function GetOperationsByTag: TPascalOperationsByTagDynArray;

    function GetDtosUnit(const UnitName: RawUtf8): RawUtf8;
    function GetClientUnit(const UnitName, ClientClassName, DtoUnitName: RawUtf8): RawUtf8;
    function Info: PDocVariantData;
    property Specs: TOpenApiSpecs
      read fSpecs;
    property Schema[const aName: RawUtf8]: POpenApiSchema
      read GetSchemaByName;
    property Operations: TPascalOperationDynArray
      read fOperations;
    property LineEnd: RawUtf8
      read fLineEnd;
    property LineIndent: RawUtf8
      read fLineIndent;
    property Version: TOpenApiVersion
      read fVersion;
  end;


const
  // published for unit testing (e.g. if properly sorted)
  RESERVED_KEYWORDS: array[0..91] of RawUtf8 = (
    'ABSOLUTE', 'ABSTRACT', 'ALIAS', 'AND', 'ARRAY', 'AS', 'ASM', 'ASSEMBLER',
    'BEGIN', 'CASE', 'CLASS', 'CONST', 'CONSTREF', 'CONSTRUCTOR', 'DESTRUCTOR',
    'DIV', 'DO', 'DOWNTO', 'ELSE', 'END', 'EXCEPT', 'EXPORT', 'EXTERNAL',
    'FALSE', 'FAR', 'FILE', 'FINALIZATION', 'FINALLY', 'FOR', 'FORWARD',
    'FUNCTION', 'GENERIC', 'GOTO', 'IF', 'IMPLEMENTATION', 'IN', 'INHERITED',
    'INITIALIZATION', 'INLINE', 'INTERFACE', 'IS', 'LABEL', 'LIBRARY', 'MOD',
    'NEAR', 'NEW', 'NIL', 'NOT', 'OBJECT', 'OF', 'ON', 'OPERATOR', 'OR', 'OUT',
    'OVERRIDE', 'PACKED', 'PRIVATE', 'PROCEDURE', 'PROGRAM', 'PROPERTY',
    'PROTECTED', 'PUBLIC', 'PUBLISHED', 'RAISE', 'READ', 'RECORD',
    'REINTRODUCE', 'REPEAT', 'RESOURCESTRING', 'SELF', 'SET', 'SHL', 'SHR',
    'STATIC', 'STRING', 'THEN', 'THREADVAR', 'TO', 'TRUE', 'TRY', 'TYPE',
    'UNIT', 'UNTIL', 'USES', 'VAR', 'VARIANT', 'VIRTUAL', 'WHILE', 'WITH',
    'WRITE', 'WRITELN', 'XOR');

/// quickly check if a text is a case-insensitive pascal code keyword
function IsReservedKeyWord(const aName: RawUtf8): boolean;

/// wrap CamelCase() and IsReservedKeyWord() to generate a valid pascal identifier
// - if aName is void after camel-casing, will raise an EOpenApi
function SanitizePascalName(const aName: RawUtf8; KeyWordCheck: boolean): RawUtf8;


implementation


{ ************************************ OpenAPI Document Wrappers }

{ TOpenApiSchema }

function TOpenApiSchema.AllOf: POpenApiSchemaDynArray;
var
  all: PDocVariantData;
  i: PtrInt;
begin
  result := nil;
  if not Data.GetAsArray('allOf', all) then
    exit;
  SetLength(result, all^.Count);
  for i := 0 to high(result) do
    result[i] := pointer(_Safe(all^.Values[i]));
end;

function TOpenApiSchema.Items: POpenApiSchema;
begin
  if not IsArray then
    EOpenApi.RaiseUtf8('TOpenApiSchema.Items on a non array: %', [_Type]);
  if not Data.GetAsObject('items', PDocVariantData(result)) then
    result := nil;
end;

function TOpenApiSchema.ItemsOrNil: POpenApiSchema;
begin
  if not IsArray or
     not Data.GetAsObject('items', PDocVariantData(result)) then
    result := nil;
end;

function TOpenApiSchema.HasItems: boolean;
begin
  result := IsArray and
            Data.Exists('items');
end;

function TOpenApiSchema.Properties: PDocVariantData;
begin
  if not Data.GetAsObject('properties', result) then
    result := nil;
end;

function TOpenApiSchema.GetPropertyByName(const aName: RawUtf8): POpenApiSchema;
begin
  if not Properties^.GetAsObject(aName, PDocVariantData(result)) then
    result := nil;
end;

function TOpenApiSchema.Reference: RawUtf8;
begin
  result := Data.U['$ref']
end;

function TOpenApiSchema.Nullable: boolean;
begin
  result := Data.B['nullable'];
end;

function TOpenApiSchema.Required: PDocVariantData;
begin
  result := Data.A['required']
end;

function TOpenApiSchema.Description: RawUtf8;
begin
  result := Data.U['description']
end;

function TOpenApiSchema.HasDescription: boolean;
begin
  result := Data.Exists('description');
end;

function TOpenApiSchema.Enum: PDocVariantData;
begin
  if not Data.GetAsArray('enum', result) then
    result := nil;
end;

function TOpenApiSchema.ExampleAsText: RawUtf8;
begin
  result := VariantSaveJson(Data.Value['example']);
end;

function TOpenApiSchema.PatternAsText: RawUtf8;
begin
  result := VariantSaveJson(Data.Value['pattern']);
end;

function TOpenApiSchema.HasExample: boolean;
begin
  result := Data.Exists('example');
end;

function TOpenApiSchema.HasPattern: boolean;
begin
  result := Data.Exists('pattern');
end;

function TOpenApiSchema._Format: RawUtf8;
begin
  result := Data.U['format'];
end;

function TOpenApiSchema._Type: RawUtf8;
begin
  result := Data.U['type'];
end;

function TOpenApiSchema.IsArray: boolean;
begin
  result := _Type = 'array';
end;

function TOpenApiSchema.IsObject: boolean;
begin
  result := _Type = 'object';
end;

function TOpenApiSchema.IsNamedEnum: boolean;
begin
  result := (Enum <> nil) and
            (_Format <> '');
end;

function TOpenApiSchema.BuiltinType: TOpenApiBuiltInType;
var
  t, f: RawUtf8;
begin
  t := _Type;
  f := _Format;
  if t = 'integer' then
    if f = 'int64' then
      result := obtInt64
    else
      result := obtInteger
  else if t = 'number' then
    if f = 'float' then
      result := obtSingle
    else
      result := obtDouble
  else if t = 'string' then
    if f = 'date' then
      result := obtDate
    else if f = 'date-time' then
      result := obtDateTime
    else if f = 'uuid' then
      result := obtGuid
    else if f = 'binary' then
      result := obtRawByteString
    else if f = 'password' then
      result := obtSpiUtf8
    else
      result := obtRawUtf8
  else if t = 'boolean' then
    result := obtBoolean
  else
    result := obtVariant; // typically a TDocVariantData
end;


{ TOpenApiResponse }

function TOpenApiResponse.Description: RawUtf8;
begin
  result := Data.U['description'];
end;

function TOpenApiResponse.Schema(Parser: TOpenApiParser): POpenApiSchema;
begin
  if Parser.Version = oav2 then
    result := POpenApiSchema(Data.O['schema'])
  else
    // we only support application/json in our wrapper classes
    result := POpenApiSchema(Data.O['content']^.O[JSON_CONTENT_TYPE].O['schema']);
  if result^.Data.Count = 0 then
    result := nil; // no such schema
end;


{ TOpenApiParameter }

function TOpenApiParameter.AllowEmptyValues: boolean;
begin
  result := Data.B['allowEmptyValue'];
end;

function TOpenApiParameter.Description: RawUtf8;
begin
  result := Data.U['description'];
end;

function TOpenApiParameter.Default: PVariant;
begin
  result := Data.GetPVariantByPath('default');
end;

function TOpenApiParameter.HasDefaultValue: boolean;
begin
  result := (Default <> nil) or not Required;
end;

function TOpenApiParameter._In: RawUtf8;
begin
  result := Data.U['in'];
end;

function TOpenApiParameter.Name: RawUtf8;
begin
  result := Data.U['name'];
end;

function TOpenApiParameter.Required: boolean;
begin
  result := Data.B['required'];
end;

function TOpenApiParameter.Schema(Parser: TOpenApiParser): POpenApiSchema;
begin
  if Parser.Version = oav2 then
    result := POpenApiSchema(@self)
  else if not Data.GetAsObject('schema', PDocVariantData(result)) then
    result := nil;
end;

function TOpenApiParameter.AsPascalName: RawUtf8;
begin
  result := SanitizePascalName(Name, {keywordcheck:}true);
end;


{ TOpenApiTag }

function TOpenApiTag.Description: RawUtf8;
begin
  if @self = nil then
    result := ''
  else
    result := Data.U['description'];
end;

function TOpenApiTag.Name: RawUtf8;
begin
  result := Data.U['name'];
end;


{ TOpenApiPathItem }

function TOpenApiPathItem.Description: RawUtf8;
begin
  result := Data.U['description'];
end;

function TOpenApiPathItem.GetOperationByMethod(aMethod: TUriMethod): POpenApiOperation;
begin
  if not Data.GetAsObject(ToText(aMethod), PDocVariantData(result)) then
    result := nil;
end;

function TOpenApiPathItem.Parameters: POpenApiParameters;
begin
  result := POpenApiParameters(Data.A['parameters']);
end;

function TOpenApiPathItem.Summary: RawUtf8;
begin
  result := Data.U['summary'];
end;


{ TOpenApiParameters }

function TOpenApiParameters.GetParameterByIndex(aIndex: integer): POpenApiParameter;
begin
  if cardinal(aIndex) >= cardinal(Data.Count) then
    EOpenApi.RaiseUtf8('Out of range TOpenApiParameters[%]', [aIndex]);
  result := @Data.Values[aIndex];
end;

function TOpenApiParameters.Count: integer;
begin
  result := Data.Count;
end;


{ TOpenApiOperation }

function TOpenApiOperation.Deprecated: boolean;
begin
  result := Data.B['deprecated'];
end;

function TOpenApiOperation.Description: RawUtf8;
begin
  result := Data.U['description'];
end;

function TOpenApiOperation.Id: RawUtf8;
begin
  result := Data.U['operationId'];
end;

function TOpenApiOperation.Parameters: POpenApiParameters;
begin
  result := POpenApiParameters(Data.A['parameters']);
end;

function TOpenApiOperation.RequestBody(Parser: TOpenApiParser): POpenApiRequestBody;
var
  p: POpenApiParameters;
  i: integer;
begin
  if Parser.Version = oav2 then
  begin
    p := Parameters;
    if p <> nil then
      for i := 0 to p.Count - 1 do
      begin
        result := POpenApiRequestBody(p.Parameter[i]);
        if POpenApiParameter(result)^._In = 'body' then
          exit;
      end;
    result := nil;
  end
  else if not Data.GetAsObject('requestBody', PDocVariantData(result)) then
    result := nil;
end;

function TOpenApiOperation.BodySchema(Parser: TOpenApiParser): POpenApiSchema;
var
  rb: POpenApiRequestBody;
begin
  rb := RequestBody(Parser);
  if Assigned(rb) then
    result := rb^.Schema(Parser)
  else
    result := nil;
end;

function TOpenApiOperation.GetResponseForStatusCode(
  aStatusCode: integer): POpenApiResponse;
var
  nam: RawUtf8;
begin
  if aStatusCode = 0 then
    nam := 'default'
  else
    UInt32ToUtf8(aStatusCode, nam);
  if not Responses^.GetAsObject(nam, PDocVariantData(result)) then
    result := nil;
end;

function TOpenApiOperation.Responses: PDocVariantData;
begin
  result := Data.O['responses'];
end;

function TOpenApiOperation.Summary: RawUtf8;
begin
  result := Data.U['summary'];
end;

function TOpenApiOperation.Tags: TRawUtf8DynArray;
begin
  Data.A['tags']^.ToRawUtf8DynArray(result);
end;


{ TOpenApiSpecs }

function TOpenApiSpecs.GetPathItemByName(const aPath: RawUtf8): POpenApiPathItem;
begin
  if not Paths^.GetAsObject(aPath, PDocVariantData(result)) then
    result := nil;
end;

function TOpenApiSpecs.Info: PDocVariantData;
begin
  result := Data.O['info'];
end;

function TOpenApiSpecs.BasePath: RawUtf8;
begin
  result := Data.U['basePath'];
end;

function TOpenApiSpecs.Paths: PDocVariantData;
begin
  result := Data.O['paths'];
end;

function TOpenApiSpecs.Tags: PDocVariantData;
begin
  result := Data.A['tags'];
end;

function TOpenApiSpecs.Version: RawUtf8;
begin
  if not Data.GetAsRawUtf8('swagger', result) then
    result := Data.U['openapi'];
end;

function TOpenApiSpecs.VersionEnum: TOpenApiVersion;
var
  aVersion: RawUtf8;
begin
  result := oavUnknown;
  aVersion := Version;
  if aVersion <> '' then
    if aVersion[1] = '2' then
      result := oav2  // Swagger 2.0 layout
    else if aVersion[1] = '3' then
      result := oav3; // OpenAPI 3.x layout
end;

function TOpenApiSpecs.Components: PDocVariantData;
begin
  result := Data.O['components'];
end;

function TOpenApiSpecs.Schemas(aVersion: TOpenApiVersion): PDocVariantData;
begin
  if aVersion = oav2 then
    result := Data.O['definitions']
  else
    result := Components.O['schemas'];
end;



{ ************************************ FPC/Delphi Pascal Code Generation }

function IsReservedKeyWord(const aName: RawUtf8): boolean;
var
  up: array[byte] of AnsiChar;
begin
  UpperCopy255Buf(@up, pointer(aName), length(aName))^ := #0;
  result := FastFindPUtf8CharSorted(
    @RESERVED_KEYWORDS, high(RESERVED_KEYWORDS), @up) >= 0; // O(log(n)) search
end;

function SanitizePascalName(const aName: RawUtf8; KeyWordCheck: boolean): RawUtf8;
begin
  CamelCase(aName, result);
  if result = '' then
    EOpenApi.RaiseUtf8('Unexpected SanitizePascalName(%)', [aName]);
  result[1] := UpCase(result[1]);
  if KeyWordCheck and
     IsReservedKeyWord(result) then
    Prepend(RawByteString(result), '_');
end;


{ TPascalCustomType }

constructor TPascalCustomType.Create(aOwner: TOpenApiParser;
  const aPascalName: RawUtf8);
begin
  fParser := aOwner;
  fPascalName := aPascalName;
end;

function TPascalCustomType.ToArrayTypeName(AsFinalType: boolean): RawUtf8;
begin
  if AsFinalType then
    result := FormatUtf8('%DynArray', [PascalName])
  else
    result := FormatUtf8('array of %', [PascalName]);
end;

function TPascalCustomType.ToArrayTypeDefinition: RawUtf8;
begin
  if fRequiresArrayDefinition then
    result := FormatUtf8('%% = %;%', [fParser.LineIndent,
      ToArrayTypeName({final=}true), ToArrayTypeName(false), fParser.LineEnd])
  else
    result := '';
end;


{ TPascalOperation }

constructor TPascalOperation.Create(aParser: TOpenApiParser;
  const aPath: RawUtf8; aPathItem: POpenApiPathItem;
  aOperation: POpenApiOperation; aMethod: TUriMethod);
var
  p, o: POpenApiParameters;
  pn, i: integer;
begin
  fParser := aParser;
  fPath := aPath;
  fPathItem := aPathItem;
  fOperation := aOperation;
  fMethod := aMethod;
  p := fPathItem^.Parameters;
  pn := p.Count;
  o := fOperation^.Parameters;
  SetLength(fParameters, pn + o.Count);
  for i := 0 to pn - 1 do
    fParameters[i] := p^.Parameter[i];
  for i := 0 to o.Count - 1 do
    fParameters[pn + i] := o^.Parameter[i];
end;

destructor TPascalOperation.Destroy;
begin
  fPayloadParameterType.Free;
  fSuccessResponseType.Free;
  ObjArrayClear(fParameterTypes);
  inherited Destroy;
end;

function TPascalOperation.ParameterType(aIndex: integer): TPascalType;
var
  i: PtrInt;
begin
  if fParameterTypes = nil then // late on-demand resolution
  begin
    SetLength(fParameterTypes, length(fParameters));
    for i := 0 to length(fParameters) - 1 do
      fParameterTypes[i] := fParser.NewPascalTypeFromSchema(
        fParameters[i]^.Schema(fParser));
  end;
  if (aIndex < 0) or
     (aIndex >= length(fParameterTypes)) then
    EOpenApi.RaiseUtf8('%.ParameterType(%)?', [self, aIndex]);
  result := fParameterTypes[aIndex];
end;

procedure TPascalOperation.ResolveResponseTypes;
var
  code: integer;
  v: PDocVariantData;
  i: PtrInt;
  e: TPascalException;
  status, err, deferr, json: RawUtf8;
  resp: POpenApiSchema;
begin
  resp := fOperation^.BodySchema(fParser);
  if Assigned(resp) then
    fPayloadParameterType := fParser.NewPascalTypeFromSchema(resp);
  v := fOperation.Responses;
  v^.SortByName(@StrCompByNumber); // sort in-place by status number
  for i := 0 to v^.Count - 1 do
  begin
    status := v^.Names[i];
    code := Utf8ToInteger(status, 0);
    resp := POpenApiResponse(@v^.Values[i])^.Schema(fParser);
    if StatusCodeIsSuccess(code) or
       ((fSuccessResponseCode = 0) and
        (status = 'default')) then
    begin
      if fSuccessResponseType = nil then // handle the first success
      begin
        fSuccessResponseCode := code;
        if resp <> nil then
          fSuccessResponseType := fParser.NewPascalTypeFromSchema(resp);
      end;
    end
    else if Assigned(resp) then
    begin
      // generate a custom EJsonClient exception class for 4xx errors
      json := resp^.Data.ToJson;
      // we don't know PascalName until it is parsed so is json-indexed
      e := fParser.fExceptions.GetObjectFrom(json);
      if e = nil then
      begin
        e := TPascalException.Create(fParser, status, @v^.Values[i]);
        fParser.fExceptions.AddObject(json, e);
      end;
      if code <> 0 then // generate "case of" block
        Append(err, ['    ', code, ':', fParser.LineEnd,
                     '      e := ',e.PascalName, ';', fParser.LineEnd])
      else if status = 'default' then
        Append(deferr, ['  else', fParser.LineEnd,
                     '    e := ',e.PascalName, ';', fParser.LineEnd])
    end;
  end;
  err := err + deferr;
  if err <> '' then
  begin
    fOnErrorIndex := FindRawUtf8(fParser.fErrorHandler, err) + 1;
    if fOnErrorIndex = 0 then // new TOnJsonClientError
      fOnErrorIndex := AddRawUtf8(fParser.fErrorHandler, err) + 1;
  end;
end;

procedure TOpenApiParser.Comment(W: TTextWriter; const Args: array of const);
var
  line, feed: RawUtf8;
  i, o: PtrInt;
begin
  line := Make(Args);
  o := 0;
  while length(line) - o > 80 do // insert line feeds on huge comment
  begin
    i := PosEx(' ', line, o + 75);
    if i = 0 then
      break;
    if feed = '' then
      feed := Make([LineEnd, LineIndent, '//']);
    insert(feed, line, i);
    o := i + length(feed);
  end;
  w.AddStrings([LineIndent, line, LineEnd]);
end;

procedure TPascalOperation.Documentation(W: TTextWriter);
var
  p: POpenApiParameter;
  v: PDocVariantData;
  status, desc, line: RawUtf8;
  code: integer;
  r: POpenApiResponse;
  i: PtrInt;
  rb: POpenApiRequestBody;
  rs: POpenApiSchema;
  e: TPascalException;
begin
  // Request Definition
  w.AddStrings([
     fParser.LineIndent, '// ', fOperation^.Id, ' [', ToText(fMethod), '] ',
       fPath, fParser.LineEnd,
     fParser.LineIndent, '//', fParser.LineEnd]);
  // Summary
  if fOperation^.Summary <> '' then
    fParser.Comment(w, ['// Summary: ', fOperation^.Summary]);
  // Description
  desc := fOperation^.Description;
  if desc <> '' then
  begin
    desc := StringReplaceAll(StringReplaceAll(desc, #10,
      FormatUtf8('%%//   ', [fParser.LineEnd, fParser.LineIndent])), #13, '');
    w.AddStrings([
      fParser.LineIndent, '// Description:', fParser.LineEnd,
      fParser.LineIndent, '//   ', desc, fParser.LineEnd]);
  end;
  // params
  rb := fOperation^.RequestBody(fParser);
  if (fParameters <> nil) or
     (Assigned(rb) and Assigned(rb^.Schema(fParser))) then
  begin
    w.AddStrings([fParser.LineIndent, '//', fParser.LineEnd,
           fParser.LineIndent, '// Params:', fParser.LineEnd]);
    for i := 0 to high(fParameters) do
    begin
      p := fParameters[i];
      if p^._In = 'body' then
        continue; // handled below
      line := Make(['// - [', p^._In, '] ', p^.AsPascalName]);
      if p^.Required then
        Append(line, '*');
      if p^.Default <> nil then
        Append(line, [' (default=', p^.Default^, ')']);
      if p^.Description <> '' then
        Append(line, ': ', p^.Description);
      fParser.Comment(w, [line]);
    end;
    // Request body
    if Assigned(rb) then
    begin
      line := '// - [body] Payload*';
      if rb^.Description <> '' then
        Append(line, ': ', rb^.Description);
      fParser.Comment(w, [line]);
    end;
  end;
  // Responses
  v := fOperation^.Responses;
  if v^.Count > 0 then
  begin
    w.AddStrings([fParser.LineIndent, '//', fParser.LineEnd,
           fParser.LineIndent, '// Responses:', fParser.LineEnd]);
    for i := 0 to v^.Count - 1 do
    begin
      status := v^.Names[i];
      code := Utf8ToInteger(status, 0);
      r := @v^.Values[i];
      rs := r^.Schema(fParser);
      line := Make(['// - ', status]);
      if code = fSuccessResponseCode then
        Append(line, ' (main)')
      else if Assigned(rs) then
      begin
        e := fParser.fExceptions.GetObjectFrom(rs^.Data.ToJson);
        if e <> nil then // no need to parse, just recognize schema
          Append(line, [' [', e.PascalName, ']']);
      end;
      if r^.Description <> '' then
        Append(line, ': ', r^.Description);
      fParser.Comment(w, [line]);
    end;
  end;
end;

const
  _CONST: array[boolean] of string[7] = ('const ', '');

procedure TPascalOperation.Declaration(W: TTextWriter; const ClassName: RawUtf8;
  InImplementation: boolean);
var
  p: POpenApiParameter;
  pt: TPascalType;
  i, ndx: PtrInt;
  line: RawUtf8;
  hasdefault: boolean;
  def: TRawUtf8DynArray;

  procedure AppLine(const Args: array of const);
  begin
    if length(line) > 70 then
    begin
      w.AddStrings([TrimRight(line), fParser.LineEnd]);
      line := fParser.LineIndent + '  ';
    end;
    Append(line, Args);
  end;

begin
  if Assigned(fSuccessResponseType) then
    line := 'function '
  else
    line := 'procedure ';
  if ClassName <> '' then
    Append(line, ClassName, '.');
  Append(line, FunctionName, '(');

  ndx := 0;
  for i := 0 to Length(fParameters) - 1 do
  begin
    p := fParameters[i];
    if (p^._In = 'path') or
       (p^._In = 'query') then
    begin
      hasdefault := (not InImplementation) and p^.HasDefaultValue;
      if not hasdefault then
      begin
        if (ndx > 0) then
          Append(line, '; ');
        inc(ndx);
      end;
      pt := ParameterType(i);
      if hasdefault then
        AddRawUtf8(def, FormatUtf8('%%: % = %', [_CONST[pt.fNoConst],
          p^.AsPascalName, pt.ToPascalName, pt.ToDefaultParameterValue(p, fParser)]))
      else
        AppLine([_CONST[pt.fNoConst], p^.AsPascalName, ': ', pt.ToPascalName]);
    end;
  end;

  if Assigned(fPayloadParameterType) then
  begin
    if ndx > 0 then
      Append(line, '; ');
    AppLine(['const Payload: ', fPayloadParameterType.ToPascalName]);
    inc(ndx);
  end;

  for i := 0 to high(def) do
  begin
    if ndx <> 0 then
      Append(line, '; ');
    AppLine([def[i]]);
    inc(ndx);
  end;

  if Assigned(fSuccessResponseType) then
    Append(line, ['): ', fSuccessResponseType.ToPascalName, ';'])
  else
    Append(line, ');');
  w.AddString(Line);
end;

procedure TPascalOperation.Body(W: TTextWriter;
  const ClassName, BasePath: RawUtf8);
var
  url: RawUtf8;
  urlArgs: TRawUtf8DynArray;
  i: PtrInt;
  queryParams: TDocVariantData;
  p: POpenApiParameter;
  pt: TPascalType;
begin
  url := BasePath + fPath;
  queryParams.InitObject([], JSON_FAST);

  for i := 0 to high(fParameters) do
  begin
    p := fParameters[i];
    pt := ParameterType(i);
    if p^._In = 'path' then
    begin
      url := StringReplaceAll(url, FormatUtf8('{%}', [p^.Name]), '%');
      AddRawUtf8(urlArgs, pt.ToFormatUtf8Arg(p^.AsPascalName));
    end
    else if p^._In = 'query' then
      queryParams.AddValue(p^.Name, pt.ToFormatUtf8Arg(p^.AsPascalName));
  end;

  Declaration(w, ClassName, {implem=}true);
  w.AddStrings([fParser.LineEnd, 'begin', fParser.LineEnd,
         '  fClient.Request(''', ToText(fMethod), ''', ''', url, '''']);
   // Path parameters
   if Length(urlArgs) > 0 then
   begin
     w.AddShorter(', [');
     for i := 0 to Length(urlArgs) - 1 do
     begin
       if i > 0 then
         w.AddShorter(', ');
       w.AddString(urlArgs[i]);
     end;
     w.AddDirect(']');
   end
   // Either urlArgs and QueryArgs or None of them (for Request parameters)
   else if (queryParams.Count > 0) or
           Assigned(fPayloadParameterType) then
     w.AddShorter(', []');

   // Query parameters
   if queryParams.Count > 0 then
   begin
     w.AddStrings([', [', fParser.LineEnd]);
     for i := 0 to queryParams.Count - 1 do
     begin
       if i > 0 then
         w.AddStrings([',', fParser.LineEnd]);
       w.AddStrings(['    ''', queryParams.Names[i], ''', ',
         VariantToUtf8(queryParams.Values[i])]);
     end;
     w.AddStrings([fParser.LineEnd, '    ]']);
   end
   // Either urlArgs and QueryArgs or None of them (for Request parameters)
   else if (urlArgs <> nil) or
           Assigned(fPayloadParameterType) then
     w.AddShorter(', []');

   // Payload if any
   if Assigned(fPayloadParameterType) then
   begin
     w.AddStrings([',', fParser.LineEnd,
       '    Payload, ']);
     if Assigned(fSuccessResponseType) then
       w.AddShorter('result')
     else
       w.AddShort('{notused:}self');

     w.AddStrings([', TypeInfo(', fPayloadParameterType.ToPascalName, '), ']);
     if Assigned(fSuccessResponseType) then
       w.AddStrings(['TypeInfo(', fSuccessResponseType.ToPascalName, ')'])
     else
       w.AddShorter('nil');
   end
   // Response type if any
   else if Assigned(fSuccessResponseType) then
     w.AddStrings([',', fParser.LineEnd,
       '    result, TypeInfo(', fSuccessResponseType.ToPascalName, ')']);
  if fOnErrorIndex <> 0 then
    w.AddStrings([', OnError', SmallUInt32Utf8[fOnErrorIndex]]);
  w.AddStrings([');', fParser.LineEnd, 'end;', fParser.LineEnd, fParser.LineEnd]);
end;

function TPascalOperation.FunctionName: RawUtf8;
begin
  result := fOperation^.Id;
  if result <> '' then
    result := SanitizePascalName(result, {keywordcheck:}true);
end;


{ TPascalProperty }

constructor TPascalProperty.CreateFromSchema(aOwner: TOpenApiParser;
  const aName: RawUtf8; aSchema: POpenApiSchema);
begin
  fType := aOwner.NewPascalTypeFromSchema(aSchema, '');
  fTypeOwned := true;
  fName := aName;
  fSchema := aSchema;
  fPascalName := SanitizePascalName(fName, {keywordcheck:}true);
end;

constructor TPascalProperty.CreateFrom(another: TPascalProperty);
begin
  fType := another.PropType; // weak copy (keep fTypeOwned=false)
  fName := another.Name;
  fSchema := another.Schema;
  fPascalName := another.PascalName;
end;

destructor TPascalProperty.Destroy;
begin
  if fTypeOwned then
    fType.Free;
  inherited Destroy;
end;


{ TPascalEnum }

constructor TPascalEnum.Create(aOwner: TOpenApiParser;
  const aName: RawUtf8; aSchema: POpenApiSchema);
var
  i: PtrInt;
begin
  inherited Create(aOwner, 'T' + SanitizePascalName(aName, {keywordcheck:}false));
  fName := aName;
  fSchema := aSchema;
  fChoices.InitCopy(Variant(aSchema^.Enum^), JSON_FAST);
  fChoices.AddItem('None', 0); // alwyas prepend a first void item
  for i := 2 to length(fPascalName) do
    if fPascalName[i] in ['A' .. 'Z'] then
      Append(fPrefix, fPascalName[i]);
  LowerCaseSelf(fPrefix); // TUserRole -> 'ur'
  FormatUtf8('%2TXT', [UpperCase(copy(fPascalName, 2, 100))], fConstTextArrayName);
end;

procedure TPascalEnum.ToTypeDefinition(W: TTextWriter);
var
  item: RawUtf8;
  items: TRawUtf8DynArray;
  i: PtrInt;
begin
  if fSchema^.HasDescription then
    fParser.Comment(W, ['/// ', fSchema^.Description]);
  w.AddStrings([fParser.LineIndent, PascalName, ' = (', fParser.LineEnd,
    fParser.LineIndent, '  ']);
  for i := 0 to fChoices.Count - 1 do
  begin
    if i = 0 then
      item := 'None'
    else
    begin
      w.AddShorter( ', ');
      CamelCase(ToUtf8(fChoices.Values[i]), item);
      if item <> '' then
        item[1] := UpCase(item[1]);
      if (item = '') or
         (FindPropName(items, item) >= 0) then
        Append(item, [i]); // duplicated, or no ascii within -> make unique
    end;
    AddRawUtf8(items, item);
    w.AddStrings([fPrefix, item]);
  end;
  w.AddStrings([');', fParser.LineEnd,
    ToArrayTypeDefinition]);
end;

procedure TPascalEnum.ToRegisterCustom(W: TTextWriter);
begin
  w.AddStrings(['    TypeInfo(', fPascalName, ')']);
  if fRequiresArrayDefinition then
    w.AddStrings([', TypeInfo(', ToArrayTypeName, ')'])
  else
    w.AddShorter(', nil');
  w.AddStrings([', @', fConstTextArrayName]);
end;

function TPascalEnum.ToArrayTypeName(AsFinalType: boolean): RawUtf8;
begin
  if AsFinalType then
    result := FormatUtf8('%Set', [PascalName])
  else
    result := FormatUtf8('set of %', [PascalName]);
end;

function TPascalEnum.ToConstTextArray: RawUtf8;
var
  i: integer;
begin
  result := FormatUtf8('%: array[%] of RawUtf8 = (%    ''''',
              [fConstTextArrayName, PascalName, fParser.LineEnd]);
  for i := 1 to fChoices.Count - 1 do // first entry is for None/Default
    Append(result, ', ',
      mormot.core.unicode.QuotedStr(VariantToUtf8(fChoices.Values[i])));
  Append(result, ');');
end;


{ TPascalType }

function TPascalType.IsBuiltin: boolean;
begin
  result := not Assigned(fCustomType);
end;

function TPascalType.GetSchema: POpenApiSchema;
begin
  if Assigned(CustomType) then
    result := CustomType.Schema
  else
    result := fBuiltinSchema;
end;

function TPascalType.IsEnum: boolean;
begin
  result := Assigned(fCustomType) and
            (fCustomType is TPascalEnum);
end;

function TPascalType.IsRecord: boolean;
begin
  result := Assigned(fCustomType) and
            (fCustomType is TPascalRecord);
end;

procedure TPascalType.SetArray(AValue: boolean);
begin
  fIsArray := AValue;
  if AValue and
     Assigned(fCustomType) then
    fCustomType.fRequiresArrayDefinition := true;
end;

const
  OBT2TXT: array[TOpenApiBuiltInType] of RawUtf8 = (
    'variant', 'integer', 'Int64', 'boolean', 'single', 'double',
    'TDate', 'TDateTime', 'TGuid', 'RawUtf8', 'SpiUtf8', 'RawByteString');

constructor TPascalType.CreateBuiltin(aBuiltinType: TOpenApiBuiltInType;
  aSchema: POpenApiSchema; aIsArray: boolean);
begin
  fBuiltinType := aBuiltinType;
  fBuiltinTypeName := OBT2TXT[aBuiltinType];
  fBuiltinSchema := aSchema;
  if not aIsArray then
    fNoConst := aBuiltinType in [obtInteger .. obtDateTime];
  SetArray(aIsArray);
end;

constructor TPascalType.CreateCustom(aCustomType: TPascalCustomType);
begin
  fCustomType := aCustomType;
  fNoConst := IsEnum;
end;

function TOpenApiParser.NewPascalTypeFromSchema(aSchema: POpenApiSchema;
  const aSchemaName: RawUtf8): TPascalType;
var
  all: POpenApiSchemaDynArray;
  ref, src, fmt, nam: RawUtf8;
  enum: PDocVariantData;
  enumType: TPascalEnum;
begin
  if aSchema = nil then
    EOpenApi.RaiseUtf8('NewPascalTypeFromSchema(%): aSchema=nil', [aSchemaName]);
  all := aSchema^.AllOf;
  if length(all) = 1 then
    aSchema := all[0]; // typically a single "$ref": "..." entry
  ref := aSchema^.Reference;
  if ref <> '' then
  begin
    // #/definitions/NewPet -> NewPet
    src := SplitRight(ref, '/');
    aSchema := Schema[src]; // resolve from main Specs
    if aSchema = nil then
      EOpenApi.RaiseUtf8('NewPascalTypeFromSchema: unknown $ref=%', [ref]);
    result := NewPascalTypeFromSchema(aSchema, src);
    if (result.CustomType <> nil) and
       (result.CustomType.fFromRef = '') then
      result.CustomType.fFromRef := ref;
  end
  else if (all <> nil) or
          aSchema^.IsObject then
    if aSchemaName = '' then
      result := TPascalType.CreateBuiltin(aSchema.BuiltinType, aSchema)
    else
      result := TPascalType.CreateCustom(GetRecord(aSchemaName))
  else if aSchema^.IsArray then
  begin
    // TODO: Handle array of arrays?
    result := NewPascalTypeFromSchema(aSchema^.Items, aSchemaName);
    result.fBuiltinSchema := aSchema;
    result.IsArray := true;
  end
  else
  begin
    enum := aSchema^.Enum;
    if enum <> nil then
    begin
      fmt := aSchema^._Format;
      if (fmt = '') and // if no "format" type name is supplied
         (aSchema^._Type = 'string') then
      begin
        fmt := enum^.ToJson; // use string values to make it genuine
        nam := aSchema^.Description;
      end
      else
        nam := fmt;
      if fmt <> '' then
      begin
        enumType := fEnums.GetObjectFrom(fmt);
        if enumType = nil then
        begin
          enumType := TPascalEnum.Create(self, nam, aSchema);
          fEnums.AddObject(fmt, enumType);
        end;
        result := TPascalType.CreateCustom(enumType);
        exit;
      end;
    end;
    result := TPascalType.CreateBuiltin(aSchema.BuiltinType, aSchema);
  end;
end;

function TPascalType.ToPascalName(AsFinalType, NoRecordArrayTypes: boolean): RawUtf8;
var
  finaltype: boolean;
begin
  if Assigned(CustomType) then
  begin
    result := CustomType.PascalName;
    if not IsArray then
      exit;
    finaltype := AsFinalType;
    if NoRecordArrayTypes and AsFinalType and IsRecord then
      finaltype := false;
    result := CustomType.ToArrayTypeName(finaltype);
  end
  else
  begin
    result := fBuiltinTypeName;
    if not IsArray then
      exit;
    if result[1] <> 'T' then
      insert('T', result, 1);
    Append(result, 'DynArray'); // use mormot.core.base arrays
  end;
end;

function TPascalType.ToFormatUtf8Arg(const VarName: RawUtf8): RawUtf8;
begin
  if IsBuiltin and
     IdemPropNameU(fBuiltinTypeName, 'TGuid') then
    result := FormatUtf8('ToUtf8(%)', [VarName])
  else if IsEnum then
    result := FormatUtf8('%[%]',
      [(fCustomType as TPascalEnum).fConstTextArrayName, VarName])
  else
    result := VarName;
end;

function TPascalType.ToDefaultParameterValue(aParam: POpenApiParameter;
  Parser: TOpenApiParser): RawUtf8;
var
  def: PVariant;
  t: RawUtf8;
begin
  def := aParam^.Default;
  if Assigned(def) and
     not VarIsEmptyOrNull(def^) then
  begin
    // explicit default value
    if PVarData(def)^.VType = varBoolean then
      result := BOOL_UTF8[PVarData(def)^.VBoolean] // normalize
    else if VariantToUtf8(def^, result) then
      result := QuotedStr(result);
  end
  else if IsEnum then
    result := (CustomType as TPascalEnum).Prefix + 'None'
  else if IsArray then
    result := 'nil'
  else
  begin
    // default from type
    t := aParam^.Schema(Parser)^._Type;
    if t = 'string' then
      result := ''''''
    else if (t = 'number') or
            (t = 'integer') then
      result := '0'
    else if t = 'boolean' then
      result := 'false'
    else
      result := 'null';
  end;
end;


{ TPascalRecord }

constructor TPascalRecord.Create(aOwner: TOpenApiParser;
  const SchemaName: RawUtf8; Schema: POpenApiSchema);
begin
  fName := SchemaName;
  fSchema := Schema;
  fProperties := TRawUtf8List.CreateEx([fObjectsOwned, fCaseSensitive, fNoDuplicate]);
  inherited Create(aOwner, 'T' + SanitizePascalName(fName, {keywordcheck:}false));
end;

destructor TPascalRecord.Destroy;
begin
  fProperties.Free;
  inherited Destroy;
end;

procedure TPascalRecord.ToTypeDefinition(W: TTextWriter);
var
  i: PtrInt;
  p: TPascalProperty;
  s: POpenApiSchema;
begin
  if fFromRef <> '' then
    fParser.Comment(w, ['/// from ', fFromRef]);
  w.AddStrings([fParser.LineIndent, PascalName, ' = packed record', fParser.LineEnd]);
  for i := 0 to fProperties.Count - 1 do
  begin
    p := fProperties.ObjectPtr[i];
    s := p.fSchema;
    if Assigned(s) and
       not s.HasDescription then
      s := pointer(s.ItemsOrNil); // fallback to enum "description"
    if Assigned(s) and
       s^.HasDescription then
    begin
      w.AddStrings([fParser.LineIndent,
          '  /// ', s^.Description, fParser.LineEnd]);
      if s^.HasExample then
        w.AddStrings([fParser.LineIndent,
          '  // - Example: ', s^.ExampleAsText, fParser.LineEnd]);
      if s^.HasPattern then
        w.AddStrings([fParser.LineIndent,
          '  // - Pattern: ', s^.PatternAsText, fParser.LineEnd]);
    end;
    w.AddStrings([fParser.LineIndent, '  ', p.PascalName, ': ',
      p.PropType.ToPascalName, ';', fParser.LineEnd]);
  end;
  w.AddStrings([fParser.LineIndent, 'end;', fParser.LineEnd,
         fParser.LineIndent, 'P', copy(PascalName, 2, length(PascalName)),
           ' = ^', PascalName, ';', fParser.LineEnd,
         ToArrayTypeDefinition, fParser.LineEnd]);
end;

function TPascalRecord.ToRttiTextRepresentation: RawUtf8;
var
  i: PtrInt;
  p: TPascalProperty;
  line: RawUtf8;
begin
  result := '';
  FormatUtf8('_% = ''', [PascalName], line);
  for i := 0 to fProperties.Count - 1 do
  begin
    if length(line) > 70 then // Delphi IDE is limited to 255 chars per line
    begin
      Append(result, [line, ''' +', fParser.LineEnd, '    ''']);
      line := '';
    end;
    p := fProperties.ObjectPtr[i];
    Append(line, [fProperties[i], ':', p.PropType.ToPascalName(true, true), ' ']);
  end;
  line[length(line)] := '''';
  Append(result, line, ';');
end;

function TPascalRecord.ToRttiRegisterDefinitions: RawUtf8;
begin
  result := FormatUtf8('TypeInfo(%), _%', [PascalName, PascalName]);
end;

procedure TPascalRecord.CopyProperties(aDest: TRawUtf8List);
var
  i: PtrInt;
begin
  if (self <> nil) and
     (aDest <> nil) then
    for i := 0 to fProperties.Count - 1 do
      aDest.AddObject(fProperties[i],
        TPascalProperty.CreateFrom(fProperties.ObjectPtr[i]));
end;


{ TPascalException }

constructor TPascalException.Create(aOwner: TOpenApiParser; const aCode: RawUtf8;
  aResponse: POpenApiResponse);
begin
  fErrorCode := aCode;
  fResponse := aResponse;
  fErrorType := aOwner.NewPascalTypeFromSchema(aResponse^.Schema(aOwner));
  if Assigned(fErrorType.CustomType) then
  begin
    fPascalName := fErrorType.CustomType.PascalName;
    fPascalName[1] := 'E'; // Txxxx -> Exxxx
  end
  else
    fPascalName := 'E' + fErrorType.fBuiltinTypeName; // should never happen
  fErrorTypeName := fErrorType.ToPascalName;
  inherited Create(aOwner, fPascalName);
end;

destructor TPascalException.Destroy;
begin
  fErrorType.Free;
  inherited Destroy;
end;

procedure TPascalException.ToTypeDefinition(W: TTextWriter);
begin
  fParser.Comment(w, [
      '/// exception raised on ', fResponse.Description, ' (', fErrorCode, ')']);
  w.AddStrings([
    fParser.LineIndent, PascalName, ' = class(EJsonClient)', fParser.LineEnd,
    fParser.LineIndent, 'protected', fParser.LineEnd,
    fParser.LineIndent, '  fError: ', fErrorTypeName, ';', fParser.LineEnd,
    fParser.LineIndent, 'public', fParser.LineEnd,
    fParser.LineIndent, '  constructor CreateResp(const Format: RawUtf8; const Args: array of const;', fParser.LineEnd,
    fParser.LineIndent, '    const Resp: TJsonResponse); override;', fParser.LineEnd,
    fParser.LineIndent, '  property Error: ', fErrorTypeName, fParser.LineEnd,
    fParser.LineIndent, '    read fError;', fParser.LineEnd,
    fParser.LineIndent, 'end;', fParser.LineEnd, fParser.LineEnd]);
end;

procedure TPascalException.Body(W: TTextWriter);
begin
  w.AddStrings(['{ ', PascalName, ' }', fParser.LineEnd, fParser.LineEnd,
    'constructor ', PascalName, '.CreateResp(const Format: RawUtf8;', fParser.LineEnd,
    '  const Args: array of const; const Resp: TJsonResponse);', fParser.LineEnd,
    'begin', fParser.LineEnd,
    '  inherited CreateResp(Format, Args, Resp);', fParser.LineEnd,
    '  LoadJson(fError, Resp.Content, TypeInfo(', fErrorTypeName,'));', fParser.LineEnd,
    'end;', fParser.LineEnd, fParser.LineEnd]);
end;


{ TOpenApiParser }

constructor TOpenApiParser.Create;
begin
  fRecords := TRawUtf8List.CreateEx([fObjectsOwned, fCaseSensitive, fNoDuplicate]);
  fEnums := TRawUtf8List.CreateEx([fObjectsOwned, fCaseSensitive, fNoDuplicate]);
  fExceptions := TRawUtf8List.CreateEx([fObjectsOwned, fCaseSensitive, fNoDuplicate]);
  fLineEnd := CRLF; // default to OS value
  FormatUtf8('Generated % by % via % - DO NOT MODIFY BY HAND!',
    [NowTextDateShort, Executable.User, Executable.ProgramName], fGeneratedBy);
  fGeneratedByLine := RawUtf8OfChar('-', length(fGeneratedBy));
end;

destructor TOpenApiParser.Destroy;
begin
  fRecords.Free;
  fEnums.Free;
  fExceptions.Free;
  ObjArrayClear(fOperations);
  inherited Destroy;
end;

procedure TOpenApiParser.Clear;
begin
  fSpecs.Data.Clear;
  fRecords.Clear;
  fEnums.Clear;
  fExceptions.Clear;
  fSchemas := nil;
  fErrorHandler := nil;
  ObjArrayClear(fOperations);
end;

function TOpenApiParser.Info: PDocVariantData;
begin
  result := fSpecs.Data.O['info'];
end;

procedure TOpenApiParser.Parse(const aSpecs: TDocVariantData);
begin
  Clear;
  fSpecs.Data.InitCopy(Variant(aSpecs), JSON_FAST);
  ParseSpecs;
end;

procedure TOpenApiParser.ParseJson(const aJson: RawUtf8);
begin
  Clear;
  fSpecs.Data.InitJson(aJson, JSON_FAST);
  ParseSpecs;
end;

procedure TOpenApiParser.ParseFile(const aJsonFile: TFileName);
begin
  Clear;
  fSpecs.Data.InitJsonFromFile(aJsonFile, JSON_FAST);
  ParseSpecs;
end;

procedure TOpenApiParser.ParseSpecs;
var
  i: PtrInt;
  v: PDocVariantData;
begin
  fVersion := fSpecs.VersionEnum;
  fSchemas := fSpecs.Schemas(fVersion);
  for i := 0 to fSchemas^.Count - 1 do
    if POpenApiSchema(@fSchemas^.Values[i])^.IsObject then
      if not fRecords.Exists(fSchemas^.Names[i]) then // parse object once
        fRecords.AddObject(
          fSchemas^.Names[i], ParseRecordDefinition(fSchemas^.Names[i]));
  v := fSpecs.Paths;
  for i := 0 to v^.Count - 1 do
    ParsePath(v^.Names[i]);
end;

function TOpenApiParser.GetSchemaByName(const aName: RawUtf8): POpenApiSchema;
begin
  if not fSchemas^.GetAsObject(aName, PDocVariantData(result)) then
    result := nil;
end;

procedure TOpenApiParser.Description(W: TTextWriter; const Described: RawUtf8);
var
  u: RawUtf8;
  v: variant;
  nfo: PDocVariantData;
begin
  nfo := fSpecs.Info;
  if nfo = nil then
    exit;
  Comment(w, ['/// ', Described, ' ', nfo^.U['title']]);
  if nfo^.GetAsRawUtf8('description', u) then
    Comment(w, ['// - ', StringReplaceAll(u, #10, #10'//   ')]);
  if LineIndent <> '' then
    exit;
  if nfo^.GetAsRawUtf8('version', u) then
    Comment(w, ['// - version ', u]);
  if nfo^.GetValueByPath('license.name', v) then
    Comment(w, ['// - OpenAPI definition licensed under ', v, ' terms']);
end;

function TOpenApiParser.ParseRecordDefinition(const aDefinitionName: RawUtf8): TPascalRecord;
var
  s: POpenApiSchema;
  i, j: PtrInt;
  def: POpenApiSchemaDynArray;
  ref: RawUtf8;
  v: PDocVariantData;
begin
  // setup the new TPascalRecord instance
  s := Schema[aDefinitionName];
  if not Assigned(s) then
    EOpenApi.RaiseUtf8('%.ParseRecordDefinition: no % definition in schema',
      [self, aDefinitionName]);
  result := TPascalRecord.Create(self, aDefinitionName, s);
  // aggregate all needed information
  def := s^.AllOf;
  if def = nil then
    if not s^.IsObject then
      EOpenApi.RaiseUtf8('%.ParseRecordDefinition: % is %, not object',
        [self, aDefinitionName, s^._Type])
    else
    begin
      SetLength(def, 1);
      def[0] := s;
    end;
  // append all fields to result.Properties
  for i := 0 to high(def) do
  begin
    s := def[i];
    // append $ref properties first - making copy of each TPascalProperty
    ref := s^.Reference;
    if ref <> '' then
      GetRecord(ref, {isref=}true).CopyProperties(result.fProperties);
    // append specific fields
    v := s^.Properties;
    if v <> nil then
      for j := 0 to v^.Count - 1 do
        result.fProperties.AddObject(v^.Names[j],
          TPascalProperty.CreateFromSchema(self, v^.Names[j], @v^.Values[j]),
          {raise=}false, {free=}nil, {replaceexisting=}true);
  end;
end;

procedure TOpenApiParser.ParsePath(const aPath: RawUtf8);
var
  m: TUriMethod;
  p: POpenApiPathItem;
  s: POpenApiOperation;
  op: TPascalOperation;
begin
  p := fSpecs.Path[aPath];
  for m := low(m) to high(m) do
  begin
    s := p^.Method[m];
    if not Assigned(s) or
       s^.Deprecated then
      continue;
    op := TPascalOperation.Create(self, aPath, p, s, m);
    op.ResolveResponseTypes;
    ObjArrayAdd(fOperations, op);
  end;
end;

function TOpenApiParser.GetRecord(aRecordName: RawUtf8;
  NameIsReference: boolean): TPascalRecord;
begin
  if NameIsReference then
    // #/definitions/NewPet -> NewPet
    aRecordName := SplitRight(aRecordName, '/');
  result := fRecords.GetObjectFrom(aRecordName);
  if result <> nil then
    exit;
  result := ParseRecordDefinition(aRecordName);
  fRecords.AddObject(aRecordName, result);
end;

function HasDependencies(const Sources: TPascalRecordDynArray;
  const Searched: TRawUtf8DynArray): boolean;
var
  found: boolean;
  name: RawUtf8;
  i, j: PtrInt;
begin
  result := false;
  for i := 0 to high(Searched) do
  begin
    name := Searched[i];
    found := false;
    for j := 0 to high(Sources) do
      if Sources[j].Name = name then
      begin
        found := true;
        break;
      end;
    if not found then
      exit;
  end;
  result := true;
end;

function TOpenApiParser.GetOrderedRecords: TPascalRecordDynArray;
var
  pending, missing: TPascalRecordDynArray;
  r: TPascalRecord;
  i: PtrInt;
begin
  result := nil;
  // direct resolution
  for i := 0 to fRecords.Count - 1 do
  begin
    r := fRecords.ObjectPtr[i];
    if not Assigned(r.fDependencies) or
           HasDependencies(result, r.fDependencies) then
      ObjArrayAdd(result, r)
    else
      ObjArrayAdd(pending, r);
  end;
  // nested resolution
  while pending <> nil do
  begin
    missing := nil;
    for i := 0 to high(pending) do
      if HasDependencies(result, pending[i].fDependencies) then
        ObjArrayAdd(result, pending[i])
      else
        ObjArrayAdd(missing, pending[i]);
    pending := missing;
  end;
end;

function TOpenApiParser.GetOperationsByTag: TPascalOperationsByTagDynArray;
var
  main: PDocVariantData;
  tag: TRawUtf8DynArray;
  i, j, k, count, ndx: PtrInt;
begin
  result := nil;
  if fOperations = nil then
    exit;
  // regroup operations per tags, eventually with result[0].Tag=nil
  count := 1;
  SetLength(result, length(fOperations) + 1);
  main := fSpecs.Tags;
  for i := 0 to length(fOperations) - 1 do
  begin
    tag := fOperations[i].fOperation^.Tags;
    if tag <> nil then
    begin
      // add to all tags by name in result[1..]
      for j := 0 to high(tag) do
      begin
        ndx := -1;
        for k := 1 to count - 1 do
          if result[k].TagName = tag[j] then
          begin
            ndx := k;
            break;
          end;
        if ndx < 0 then
        begin
          ndx := count;
          inc(count);
          result[ndx].TagName := tag[j];
          main.GetAsObject(tag[j], PDocVariantData(result[ndx].Tag)); // maybe nil
        end;
        ObjArrayAdd(result[ndx].Operations, fOperations[i]);
      end;
    end
    else
      // if not tag involved, just append in result[0]
      ObjArrayAdd(result[0].Operations, fOperations[i]);
  end;
  SetLength(result, count);
  // caller will ensure a single fOperations[] method will be generated
end;

function TOpenApiParser.GetDtosUnit(const UnitName: RawUtf8): RawUtf8;
var
  rec: TPascalRecordDynArray;
  i: PtrInt;
  temp: TTextWriterStackBuffer;
  w: TTextWriter;
begin
  w := TTextWriter.CreateOwnedStream(temp);
  try
    // unit common definitions
    fLineIndent := '';
    Description(w, 'DTOs for');
    w.AddStrings([
      'unit ', UnitName, ';', LineEnd , LineEnd,
      '{$I mormot.defines.inc}', LineEnd ,
      LineEnd,
      'interface', LineEnd,
      LineEnd,
      '// ', Info^.U['title'], ' DTOs', LineEnd,
      '// ', fGeneratedByLine, LineEnd,
      '// ', fGeneratedBy, LineEnd,
      '// ', fGeneratedByLine, LineEnd,
      LineEnd,
      'uses', LineEnd,
      '  classes,', LineEnd,
      '  sysutils,', LineEnd,
      '  mormot.core.base,', LineEnd,
      '  mormot.core.rtti,', LineEnd,
      '  mormot.core.json;', LineEnd,
      LineEnd,
      'type', LineEnd, LineEnd]);
    // append all enumeration types
    fLineIndent := '  ';
    if fEnums.Count > 0 then
    begin
      w.AddStrings(['{ ************ Enumerations and Sets }', LineEnd, LineEnd]);
      for i := 0 to fEnums.Count - 1 do
        TPascalEnum(fEnums.ObjectPtr[i]).ToTypeDefinition(w);
      w.AddStrings([LineEnd, LineEnd]);
    end;
    // append all records
    w.AddStrings(['{ ************ Data Transfert Objects }', LineEnd, LineEnd]);
    rec := GetOrderedRecords;
    for i := 0 to high(rec) do
      rec[i].ToTypeDefinition(w);
    // enumeration-to-text constants
    if fEnums.Count > 0 then
    begin
      w.AddStrings([LineEnd, LineEnd, 'const', LineEnd,
        '  // define how enums/sets are actually transmitted as JSON array of string', LineEnd]);
      for i := 0 to fEnums.Count - 1 do
        w.AddStrings([LineIndent, TPascalEnum(fEnums.ObjectPtr[i]).ToConstTextArray, LineEnd]);
    end;
    // start implementation section
    w.AddStrings([LineEnd, LineEnd,
      'implementation', LineEnd, LineEnd,
      '{ ************ Custom RTTI/JSON initialization }', LineEnd, LineEnd]);
    // output the text representation of all records
    // with proper json names (overriding the RTTI definitions)
    if rec <> nil then
    begin
      w.AddStrings(['const', LineEnd,
        '  // exact definition of the DTOs expected JSON serialization', LineEnd]);
      for i := 0 to high(rec) do
        w.AddStrings([LineIndent, rec[i].ToRttiTextRepresentation, LineEnd]);
    end;
    // define the RTTI registratoin procedure
    w.AddStrings([LineEnd, LineEnd,
      'procedure RegisterRtti;', LineEnd,
      'begin', LineEnd]);
    // register all needed enum types RTTI
    if fEnums.Count > 0 then
    begin
      w.AddStrings(['  TRttiJson.RegisterCustomEnumValues([', LineEnd]);
      for i := 0 to fEnums.Count - 1 do
      begin
        if i > 0 then
          w.AddStrings([',', LineEnd]);
        TPascalEnum(fEnums.ObjectPtr[i]).ToRegisterCustom(w);
      end;
      w.AddStrings([']);', LineEnd]);
    end;
    // register all record types RTTI
    if rec <> nil then
    begin
      w.AddStrings(['  Rtti.RegisterFromText([', LineEnd]);
      for i := 0 to high(rec) do
      begin
        if i > 0 then
          w.AddStrings([',', LineEnd]);
        w.AddStrings(['    ', rec[i].ToRttiRegisterDefinitions]);
      end;
      w.AddStrings([']);', LineEnd,
        'end;', LineEnd, LineEnd]);
    end;
    // finish the unit
    w.AddStrings([
      'initialization', LineEnd,
      '  RegisterRtti;', LineEnd,
      LineEnd,
      'end.', LineEnd]);
    w.SetText(result);
  finally
    w.Free;
  end;
end;

function TOpenApiParser.GetClientUnit(
  const UnitName, ClientClassName, DtoUnitName: RawUtf8): RawUtf8;
var
  bytag: TPascalOperationsByTagDynArray;
  done: TRawUtf8DynArray;
  ops: TPascalOperationsByTag;
  op: TPascalOperation;
  id, desc, err, u: RawUtf8;
  bannerlen, i, j: PtrInt;
  temp: TTextWriterStackBuffer;
  w: TTextWriter;
begin
  w := TTextWriter.CreateOwnedStream(temp);
  try
    // unit common definitions
    fLineIndent := '';
    Description(w, 'Client unit for');
    w.AddStrings([
      'unit ', UnitName, ';', LineEnd,
      LineEnd,
      '{$I mormot.defines.inc}', LineEnd ,
      LineEnd,
      'interface', LineEnd,
      LineEnd,
      '// ', Info^.U['title'], ' Client as ', ClientClassName, ' class', LineEnd,
      '// ', fGeneratedByLine, LineEnd,
      '// ', fGeneratedBy, LineEnd,
      '// ', fGeneratedByLine, LineEnd,
      LineEnd,
      'uses', LineEnd,
      '  classes,', LineEnd,
      '  sysutils,', LineEnd,
      '  mormot.core.base,', LineEnd,
      '  mormot.core.text,', LineEnd,
      '  mormot.core.rtti,', LineEnd,
      '  mormot.core.json,', LineEnd,
      '  mormot.core.variants,', LineEnd,
      '  mormot.net.client,', LineEnd,
      '  ', DtoUnitName, ';', LineEnd, LineEnd,
      'type', LineEnd]);
    fLineIndent := '  ';
    // custom exceptions definitions
    if fExceptions.Count > 0 then
    begin
      w.AddStrings([LineEnd, '{ ************ Custom Exceptions }', LineEnd, LineEnd]);
      for i := 0 to fExceptions.Count - 1 do
        TPascalException(fExceptions.ObjectPtr[i]).ToTypeDefinition(w);
    end;
    // main client class definition
    w.AddStrings([LineEnd,
      '{ ************ Main ', ClientClassName, ' Class }', LineEnd, LineEnd]);
    Description(w,'Client class for');
    w.AddStrings([
      '  ', ClientClassName, ' = class', LineEnd,
      '  private', LineEnd,
      '    fClient: IJsonClient;', LineEnd]);
    // status responses to exception events
    if fErrorHandler <> nil then
    begin
      w.AddStrings(['    // TOnJsonClientError event handler',
        PLURAL_FORM[length(fErrorHandler) > 1], LineEnd]);
      for i := 0 to high(fErrorHandler) do
        w.AddStrings([
          '    procedure OnError', SmallUInt32Utf8[i + 1],
          '(const Sender: IJsonClient;', LineEnd,
          '      const Response: TJsonResponse; const ErrorMsg: shortstring);', LineEnd]);
    end;
    w.AddStrings([
      '  public', LineEnd, LineEnd,
      '    // initialize this Client with an associated HTTP/JSON request', LineEnd,
      '    constructor Create(const aClient: IJsonClient = nil);', LineEnd]);
    // append all methods, regrouped per tag (if any)
    fLineIndent := '    ';
    bytag := GetOperationsByTag;
    for i := 0 to high(bytag) do
    begin
      ops := bytag[i];
      if ops.Operations = nil then
        continue; // nothing to add (e.g. i=0)
      bannerlen := 0;
      for j := 0 to high(ops.Operations) do
      begin
        op := ops.Operations[j];
        id := op.fOperation^.Id;
        if FindRawUtf8(done, id) >= 0 then
          // operations can be in multiple tags but should be written once
          continue;
        AddRawUtf8(done, id);
        if (bannerlen = 0) and
           (ops.TagName <> '') then // regrouped by tag, if any
        begin
          desc := ops.Tag^.Description;
          bannerlen := 18 + Length(ops.TagName) + Length(desc);
          u := RawUtf8OfChar('/', bannerlen);
          w.AddStrings([LineEnd, LineEnd,
            '    ////', u, LineEnd,
            '    //// ---- ', ops.TagName, ': ', desc, ' ---- ////', LineEnd,
            '    ////', u, LineEnd]);
        end;
        w.AddString(LineEnd);
        op.Documentation(w);
        w.AddString(LineIndent);
        op.Declaration(w, '', {implem=}false);
        w.AddString(LineEnd);
      end;
    end;
    // finalize the class definition and start the implementation section
    w.AddStrings([LineEnd,
      '    // access to the associated HTTP/JSON request', LineEnd,
      '    property JsonClient: IJsonClient', LineEnd,
      '      read fClient write fClient;', LineEnd,
      '  end;', LineEnd,
      LineEnd, LineEnd,
      'implementation', LineEnd, LineEnd, LineEnd]);
    // custom exceptions implementations
    if fExceptions.Count > 0 then
    begin
      w.AddStrings(['{ ************ Custom Exceptions }', LineEnd, LineEnd]);
      for i := 0 to fExceptions.Count - 1 do
        TPascalException(fExceptions.ObjectPtr[i]).Body(w);
    end;
    // main client class implementation
    fLineIndent := '';
    w.AddStrings([LineEnd,
      '{ ************ Main ', ClientClassName, ' Class }', LineEnd, LineEnd,
      '{ ', ClientClassName, '}', LineEnd, LineEnd,
      'constructor ', ClientClassName, '.Create(const aClient: IJsonClient);', LineEnd,
      'begin', LineEnd,
      '  fClient := aClient;', LineEnd,
      'end;', LineEnd, LineEnd]);
    // status responses to exception events
    for i := 0 to high(fErrorHandler) do
    begin
      w.AddStrings([
        'procedure ', ClientClassName, '.OnError', SmallUInt32Utf8[i + 1],
            '(const Sender: IJsonClient;', LineEnd,
        '  const Response: TJsonResponse; const ErrorMsg: shortstring);', LineEnd]);
      err := fErrorHandler[i];
      j := PosEx('  else', err);
      if j = 1 then
        w.AddStrings([ // single default exception
          'begin', LineEnd,
          '  raise', Split(SplitRight(err, '='), ';')]) // extract class name
      else
      begin
        w.AddStrings([
          'var', LineEnd,
          '  e: EJsonClientClass;', LineEnd,
          'begin', LineEnd,
          '  case Response.Status of', LineEnd,
          err]); // exception block
        if j = 0 then
          w.AddStrings([
            '  else', LineEnd,
            '    e := EJsonClient;', LineEnd]); // no default exception class
        w.AddStrings([
          '  end;', LineEnd,
          '  raise e']);
      end;
      w.AddStrings([
        '.CreateResp(''%.%'', [self, ErrorMsg], Response);', LineEnd,
        'end;', LineEnd, LineEnd]);
    end;
    // append all methods, in native order (no need to follow tag ordering)
    for i := 0 to high(Operations) do
      Operations[i].Body(w, ClientClassName, fSpecs.BasePath);
    w.AddStrings([LineEnd, 'end.']);
    w.SetText(result);
  finally
    w.Free;
  end;
end;

procedure TOpenApiParser.ExportToDirectory(const Name: RawUtf8;
  const DirectoryName: TFileName; const UnitPrefix: RawUtf8);
var
  dtounit, clientunit: RawUtf8;
  dtofn, clientfn: TFileName;
begin
  dtounit := FormatUtf8('%%.dto', [UnitPrefix, Name]);
  dtofn := MakePath([DirectoryName, dtounit + '.pas']);
  clientunit := FormatUtf8('%%.client', [UnitPrefix, Name]);
  clientfn := MakePath([DirectoryName, clientunit + '.pas']);
  FileFromString(GetDtosUnit(dtounit), dtofn);
  FileFromString(GetClientUnit(clientunit, FormatUtf8('T%Client', [Name]), dtounit), clientfn);
end;


end.

