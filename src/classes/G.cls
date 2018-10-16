/**
 * MIT License
 *
 * Copyright (c) 2018 Click to Cloud Pty Ltd
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 **/
/**
 * Entry point for GraphQL-Lite features in Apex
 *
 * Due to the limitation of Salesforce Apex, G.apex is a simplified implementation of GraphQl
 * While the concepts are consistent, the contracts are not the same and hence not compatible
 *
 * We replace GraphQL syntax with JSON syntax to make it easier for Apex to parse the query
 *
 * Each object computed is represented in a Map<String, Object>
 * So the common structure is nested maps in G.apex
 *
 * However, if you have understanding in GraphQL, G.apex will be fairly easy to pick up
 *
 * Please see GDemoController for detailed examples of how to use G.apex
 * */
public class G {
    // Define the common data types supported in G.apex

    /**
     * Boolean type
     * */
    public static final String TYPE_BOOLEAN = 'Boolean';

    /**
     * Integer type
     * */
    public static final String TYPE_INTEGER = 'Integer';

    /**
     * Long type
     * */
    public static final String TYPE_LONG = 'Long';

    /**
     * Double type
     * */
    public static final String TYPE_DOUBLE = 'Double';

    /**
     * Datetime type
     * */
    public static final String TYPE_DATETIME = 'Datetime';

    /**
     * Date type
     * */
    public static final String TYPE_DATE = 'Date';

    /**
     * String type
     * */
    public static final String TYPE_STRING = 'String';

    /**
     * List type
     * */
    public static final String TYPE_LIST = 'List';

    /**
     * Map type
     * */
    public static final String TYPE_MAP = 'Map';

    /**
     * Object type
     * */
    public static final String TYPE_OBJECT = 'Object';

    /**
     * Reference type
     *
     * Special type used to reference Object to avoid certain referencing issues
     * */
    public static final String TYPE_REFERENCE = 'Reference';

    // Below DataTypes are singleton. No need to construct them.

    /**
     * Boolean DataType
     * */
    public static final DataType BooleanType = new SimpleType(TYPE_BOOLEAN);

    /**
     * Integer DataType
     * */
    public static final DataType IntegerType = new SimpleType(TYPE_INTEGER);

    /**
     * Long DataType
     * */
    public static final DataType LongType = new SimpleType(TYPE_LONG);

    /**
     * Double DataType
     * */
    public static final DataType DoubleType = new SimpleType(TYPE_DOUBLE);

    /**
     * Datetime DataType
     * */
    public static final DataType DatetimeType = new SimpleType(TYPE_DATETIME);

    /**
     * Date DataType
     * */
    public static final DataType DateType = new SimpleType(TYPE_DATE);

    /**
     * String DataType
     * */
    public static final DataType StringType = new SimpleType(TYPE_STRING);

    // Below are the used signs in G.apex

    /**
     * Sign for parameters
     * */
    public static final String PARAMETER_SIGN = '@';

    /**
     * Sign for aliases
     * */
    public static final String ALIAS_SIGN = ':';

    /**
     * Sign for fragments
     * */
    public static final String FRAGMENT_SIGN = '...';

    /**
     * Sign for variables
     * */
    public static final String VARIABLE_SIGN = '$';

    /**
     * Sign for directives
     * */
    public static final String DIRECTIVE_SIGN = '#';

    // Debug flag
    private static Boolean isDebug = false;

    // Registered Object Types
    private static final Map<String, ObjectType> registeredObjectTypes = new Map<String, ObjectType>();

    // Registered Schema
    private static Schema registeredSchema = null;

    // Registered Directives
    private static final Map<String, Directive> registeredDirectives = new Map<String, Directive>();

    // Load default directives
    static {
        registerDirective(new IncludeDirective());
        registerDirective(new SkipDirective());
    }

    /**
     * Execute query on the schema
     *
     * Example:
     * G.Schema schema = new G.Schema();
     * Object data = G.execute(schema, query);
     *
     * @param schema The schema
     * @param query The JSON query
     * @return Object
     * */
    public static Object execute(Schema schema, String query) {
        return execute(schema, (Map<String, Object>)JSON.deserializeUntyped(query));
    }

    /**
     * Execute query data on the schema
     *
     * Example:
     * G.Schema schema = new G.Schema();
     * Map<String, Object> queryData = new Map<String, Object>{};
     * Object data = G.execute(schema, queryData);
     *
     * @param schema The schema
     * @param queryData The nested map of query data
     * @return Object
     * */
    public static Object execute(Schema schema, Map<String, Object> queryData) {
        if(schema == null) {
            throw new GException('Schema is required');
        }

        return schema.execute(queryData);
    }

    /**
     * Execute query data on the registered schema
     *
     * Example:
     * Map<String, Object> queryData = new Map<String, Object>{};
     * Object data = G.execute(queryData);
     *
     * @param queryData The nested map of query data
     * @return Object
     * */
    public static Object execute(Map<String, Object> queryData) {
        return execute(registeredSchema, queryData);
    }

    /**
     * Execute query on the registered schema
     *
     * Example:
     * Object data = G.execute(query);
     *
     * @param query The JSON query
     * @return Object
     * */
    public static Object execute(String query) {
        return execute(registeredSchema, query);
    }

    /**
     * Get the registered object type
     *
     * Example:
     * G.ObjectType objectType = G.getObjectType('Book');
     *
     * @param name The object type name
     * @return ObjectType
     * */
    public static ObjectType getObjectType(String name) {
        return registeredObjectTypes.get(name);
    }

    /**
     * Describe the given object type by name
     * Return the description of the schema if no object type given
     *
     * Example:
     * Map<String, String> result = G.describe('Book');
     *
     * @param objectType The object type name
     * @return Map<String, String>
     * */
    public static Map<String, Object> describe(String objectType) {
        if(String.isBlank(objectType)) {
            if(registeredSchema != null) {
                return registeredSchema.describe();
            }
        }
        else {
            ObjectType type = getObjectType(objectType);
            if(type != null) {
                return type.describe();
            }
        }

        return null;
    }

    /**
     * Register a custom direcitve
     *
     * Example:
     * G.registerDirective(new MyCustomDirective());
     *
     * @param customDirective The custom directive
     * */
    public static void registerDirective(Directive customDirective) {
        if(customDirective != null) {
            registeredDirectives.put(customDirective.getName(), customDirective);
        }
    }

    // Print debug message
    private static void debug(String message) {
        if(isDebug) {
            System.debug(message);
        }
    }

    // Parse the raw key to get the alias and the real key
    private static List<String> getAliasAndKey(String rawKey) {
        List<String> result = new List<String>();
        if(rawKey.contains(ALIAS_SIGN)) {
            List<String> items = rawKey.split(ALIAS_SIGN);
            result.addAll(items);
        }
        else {
            result.add(rawKey);
            result.add(rawKey);
        }

        return result;
    }

    // Extract the realy object type from reference/list/list of reference
    private static ObjectType extractObjectType(DataType type) {
        ObjectType fieldType = null;
        if(type instanceof ObjectType) {
            fieldType = (ObjectType)type;
        }
        else if(type instanceof ReferenceType) {
            fieldType = ((ReferenceType)type).getReferencedType();
        }
        else if(type instanceof ListType) {
            DataType elementType = ((ListType)type).getElementType();
            if(elementType instanceof ObjectType) {
                fieldType = (ObjectType)elementType;
            }
            else if(elementType instanceof ReferenceType) {
                fieldType = ((ReferenceType)elementType).getReferencedType();
            }
        }
        else if(type instanceof MapType) {
            DataType elementType = ((MapType)type).getElementType();
            if(elementType instanceof ObjectType) {
                fieldType = (ObjectType)elementType;
            }
            else if(elementType instanceof ReferenceType) {
                fieldType = ((ReferenceType)elementType).getReferencedType();
            }
        }

        return fieldType;
    }

    // Get the sub map from the source map by key
    private static Map<String, Object> getSubMap(Map<String, Object> srcMap, String key) {
        Object value = srcMap.get(key);
        if(value instanceof Map<String, Object>) {
            return (Map<String, Object>)value;
        }
        else {
            return new Map<String, Object>();
        }
    }

    /**
     * The base DataType for G.apex
     *
     * DataTypes are used to constrain the data transferred
     * */
    public virtual class DataType {
        private String type;

        /**
         * Construct a DataType by the type name
         *
         * @param type The type name
         * */
        public DataType(String type) {
            this.type = type;
        }

        /**
         * Get the name of the type
         *
         * @return String
         * */
        public String getType() {
            return this.type;
        }
    }

    /**
     * Simple DataTypes that do not need to be constructed multiple times
     * */
    public class SimpleType extends DataType {
        public SimpleType(String type) {
            super(type);
        }

        public override String toString() {
            return this.getType();
        }
    }

    /**
     * List DataType
     *
     * A ListType should specify the type of the element
     * */
    public class ListType extends DataType {
        private DataType elementType;

        /**
         * Construct a ListType by the element type
         * */
        public ListType(DataType elementType) {
            super(TYPE_LIST);

            if(elementType == null) {
                throw new GException('Element type is required');
            }
            this.elementType = elementType;
        }

        /**
         * Get the element type
         *
         * @return DataType
         * */
        public DataType getElementType() {
            return this.elementType;
        }

        public override String toString() {
            return this.getType() + '<' + this.elementType.toString() + '>';
        }
    }

    /**
     * Map DataType
     *
     * A MapType should specify the type of the element
     * */
    public class MapType extends DataType {
        private DataType elementType;

        /**
         * Construct a MapType by the element type
         * */
        public MapType(DataType elementType) {
            super(TYPE_MAP);

            if(elementType == null) {
                throw new GException('Element type is required');
            }
            this.elementType = elementType;
        }

        /**
         * Get the element type
         *
         * @return DataType
         * */
        public DataType getElementType() {
            return this.elementType;
        }

        public override String toString() {
            return this.getType() + '<' + this.elementType.toString() + '>';
        }
    }

    /**
     * The Object DataType to represent the most common data
     *
     * The SObject type/fields info could be bound to the ObjectType, so that in resolvers,
     * we can easily query and convert the SObjects
     * */
    public class ObjectType extends DataType {
        // The name of the ObjectType
        private String name;

        // The bound SObject type
        private String sObjectType;

        // ObjectType fields
        private Map<String, ObjectTypeField> fields = new Map<String, ObjectTypeField>();

        /**
         * Construct an ObjectType from the name and SObject type
         *
         * Example:
         * new G.ObjectType('Book', 'Book__c');
         *
         * @param name The object type name
         * @param sObjectType The name of the SObject type
         * */
        public ObjectType(String name, String sObjectType) {
            super(TYPE_OBJECT);

            if(name == null) {
                throw new GException('Object type name is required');
            }
            this.name = name;
            this.sObjectType = sObjectType;

            registeredObjectTypes.put(name, this);
        }

        /**
         * Construct an ObjectType from the name
         *
         * Example:
         * new G.ObjectType('Author')
         *
         * @param name The name of the object type
         * */
        public ObjectType(String name) {
            this(name, null);
        }

        /**
         * Get the name of the object type
         *
         * Example:
         * G.ObjectType ot = new G.ObjectType('Book');
         * String name = ot.getName(); // Book
         *
         * @return String
         * */
        public String getName() {
            return this.name;
        }

        /**
         * Get the bound SObject type name
         *
         * Example:
         * G.ObjectType ot = new G.ObjectType('Book', 'Book__c');
         * String sObjectType = ot.getSObjectType(); // Book__c
         *
         * @return String
         * */
        public String getSObjectType() {
            return G.addNamespace(this.sObjectType);
        }

        /**
         * Add a field to the object type
         *
         * Example:
         * new G.ObjectType('Book')
         *     .addField('author', new G.ReferenceType('Author'), new BookAuthorResolveFunc(), true, 'Author__c');
         *
         * @param name The name of the field
         * @param type The data type of the field
         * @param resolve The Func used to resolve the field value
         * @param resolveBatch Whether the Func will use a batch call to resolve the field values
         * @param sObjectField The bound SObject field name
         * @return ObjectType
         * */
        public ObjectType addField(String name, DataType type, Func resolve, Boolean resolveBatch, String sObjectField) {
            if(name == null) {
                throw new GException('Object field name is required');
            }
            if(type == null) {
                type = StringType;
            }

            this.fields.put(name, new ObjectTypeField(name, type, resolve, resolveBatch, sObjectField));

            return this;
        }

        /**
         * Add a field to the object type
         *
         * Example:
         * new G.ObjectType('Book')
         *     .addField('author', new G.ReferenceType('Author'), new BookAuthorResolveFunc(), true);
         *
         * @param name The name of the field
         * @param type The data type of the field
         * @param resolve The Func used to resolve the field value
         * @param resolveBatch Whether the Func will use a batch call to resolve the field values
         * @return ObjectType
         * */
        public ObjectType addField(String name, DataType type, Func resolve, Boolean resolveBatch) {
            return this.addField(name, type, resolve, resolveBatch, null);
        }

        /**
         * Add a field to the object type
         *
         * Example:
         * new G.ObjectType('Book')
         *     .addField('author', new G.ReferenceType('Author'), new BookAuthorResolveFunc());
         *
         * @param name The name of the field
         * @param type The data type of the field
         * @param resolve The Func used to resolve the field value
         * @return ObjectType
         * */
        public ObjectType addField(String name, DataType type, Func resolve) {
            return this.addField(name, type, resolve, true);
        }

        /**
         * Add a field to the object type
         *
         * Example:
         * new G.ObjectType('Book')
         *     .addField('author', new G.ReferenceType('Author'), new BookAuthorBatchResolver());
         *
         * @param name The name of the field
         * @param type The data type of the field
         * @param resolver The batch resolver to resolve the field value
         * @return ObjectType
         * */
        public ObjectType addField(String name, DataType type, BatchResolver resolver) {
            return this.addField(name, type, new BatchResolverFunc(resolver), true);
        }

        /**
         * Add a field to the object type
         *
         * Example:
         * new G.ObjectType('Book')
         *     .addField('author', new G.ReferenceType('Author'), new BookAuthorResolver());
         *
         * @param name The name of the field
         * @param type The data type of the field
         * @param resolver The resolver to resolve the field value
         * @return ObjectType
         * */
        public ObjectType addField(String name, DataType type, Resolver resolver) {
            return this.addField(name, type, new ResolverFunc(resolver), false);
        }

        /**
         * Add a field to the object type
         *
         * Example:
         * new G.ObjectType('Book')
         *     .addField('name', G.StringType, 'Name');
         *
         * @param name The name of the field
         * @param type The data type of the field
         * @param sObjectField The bound SObject field name
         * @return ObjectType
         * */
        public ObjectType addField(String name, DataType type, String sObjectField) {
            return this.addField(name, type, null, true, sObjectField);
        }

        /**
         * Add a field to the object type
         *
         * Example:
         * new G.ObjectType('Book')
         *     .addField('name', G.StringType);
         *
         * @param name The name of the field
         * @param type The data type of the field
         * @return ObjectType
         * */
        public ObjectType addField(String name, DataType type) {
            return this.addField(name, type, null, true);
        }

        /**
         * Add a parameter to the field
         *
         * Example:
         * new G.ObjectType('query')
         *     .addField('book', new G.ReferenceType('Book'), new QueryBookResolver())
         *         .addParam('book', 'id', G.StringType, R.isNotNull);
         *
         * @param fieldName Specify which field this param will be added to
         * @param name The name of the field
         * @param type The DataType of the field
         * @param validate The validation Func of the field
         * @return ObjectType
         * */
        public ObjectType addParam(String fieldName, String name, DataType type, Func validate) {
            if(fieldName == null) {
                throw new GException('Object field name is required');
            }
            if(name == null) {
                throw new GException('Object param name is required');
            }
            if(type == null) {
                type = StringType;
            }

            ObjectTypeField field = this.fields.get(fieldName);
            field.params.put(name, new ObjectTypeParam(name, type, validate));

            return this;
        }

        /**
         * Add a parameter to the field
         *
         * Example:
         * new G.ObjectType('query')
         *     .addField('book', new G.ReferenceType('Book'), new QueryBookResolver())
         *         .addParam('book', 'id', G.StringType);
         *
         * @param fieldName Specify which field this param will be added to
         * @param name The name of the field
         * @param type The DataType of the field
         * @return ObjectType
         * */
        public ObjectType addParam(String fieldName, String name, DataType type) {
            return this.addParam(fieldName, name, type, null);
        }

        /**
         * Get the SObject fields mapping
         *
         * Example:
         * G.ObjectType ot = new G.ObjectType('Book')
         *     .addField('name', G.StringType, 'Name');
         * Map<String, String> mapping = ot.getSObjectFieldMapping();
         * // { 'name' => 'Name' }
         *
         * @return Map<String, String>
         * */
        public Map<String, String> getSObjectFieldMapping() {
            Map<String, String> result = new Map<String, String>();

            for(ObjectTypeField field : this.fields.values()) {
                if(field.sObjectField != null) {
                    String sObjectField = R.of(field.sObjectField)
                        .split('\\.')
                        .doMap(new AddNamespaceFunc())
                        .doJoin('.').toString();
                    result.put(field.name, sObjectField);
                }
            }

            return result;
        }

        // Get resolving arguments from the query map
        private Map<String, Object> getArgs(ObjectTypeField field, Map<String, Object> queryMap) {
            Map<String, Object> args = new Map<String, Object>();

            for(String paramName : field.params.keySet()) {
                ObjectTypeParam param = field.params.get(paramName);
                if(queryMap.containsKey(PARAMETER_SIGN + paramName)) {
                    Object paramValue = queryMap.get(PARAMETER_SIGN + paramName);

                    // convert value
                    paramValue = convertValue(paramValue, param.type);

                    // validate value
                    Boolean pass = true;
                    if(param.validate != null) {
                        pass = (Boolean)R.toBoolean.run(param.validate.run(paramValue));
                    }

                    if(!pass) {
                        throw new GException('Invalid param value for ' + PARAMETER_SIGN + paramName + ' in ' + this.name);
                    }

                    args.put(paramName, paramValue);
                }
            }

            return args;
        }

        // Convert the value according to the data type
        private Object convertValue(Object rawValue, DataType type) {
            if(type == BooleanType) {
                return R.toBoolean.run(rawValue);
            }
            else if(type == IntegerType) {
                return R.toInteger.run(rawValue);
            }
            else if(type == LongType) {
                return R.toLong.run(rawValue);
            }
            else if(type == DoubleType) {
                return R.toDouble.run(rawValue);
            }
            else if(type == DatetimeType) {
                return R.toDatetime.run(rawValue);
            }
            else if(type == DateType) {
                return R.toDate.run(rawValue);
            }
            else if(type == StringType) {
                return R.toString.run(rawValue);
            }
            else if(type instanceof ListType) {
                List<Object> result = new List<Object>();
                DataType elementType = ((ListType)type).getElementType();

                if(rawValue instanceof List<Object>) {
                    for(Object raw : (List<Object>)rawValue) {
                        result.add(convertValue(raw, elementType));
                    }
                }

                return result;
            }
            else if(type instanceof MapType) {
                Map<String, Object> result = new Map<String, Object>();
                DataType elementType = ((MapType)type).getElementType();

                if(rawValue instanceof Map<String, Object>) {
                    Map<String, Object> m = (Map<String, Object>)rawValue;
                    for(String key : m.keySet()) {
                        Object value = m.get(key);
                        result.put(key, convertValue(value, elementType));
                    }
                }

                return result;
            }
            else if(type instanceof ObjectType) {
                Map<String, Object> result = new Map<String, Object>();

                if(rawValue instanceof Map<String, Object>) {
                    Map<String, Object> rawMap = (Map<String, Object>)rawValue;

                    ObjectType ot = (ObjectType)type;
                    for(ObjectTypeField field : ot.fields.values()) {
                        String fieldName = field.name;
                        DataType fieldType = field.type;
                        if(rawMap.containsKey(fieldName)) {
                            Object raw = rawMap.get(fieldName);
                            result.put(fieldName, convertValue(raw, fieldType));
                        }
                    }
                }

                return result;
            }
            else if(type instanceof ReferenceType) {
                return convertValue(rawValue, ((ReferenceType)type).getReferencedType());
            }
            else {
                return rawValue;
            }
        }

        /**
         * Execute the object type on the data list with the query data
         * Mainly used in schema execution
         *
         * @param dataList
         * @param queryData
         * @return List<Object>
         * */
        public List<Object> execute(List<Object> dataList, Map<String, Object> queryData) {
            debug('--- Begin Executing ---');
            debug('dataList: ' + dataList);
            debug('queryData: ' + queryData);

            // construct pairing result
            List<Object> resultList = new List<Object>();
            for(Object dataObj : dataList) {
                resultList.add(new Map<String, Object>());
            }

            for(String rawKey : queryData.keySet()) {
                debug('Processing ' + rawKey);

                // skip parameters
                if(rawKey.startsWith(PARAMETER_SIGN)) {
                    continue;
                }

                // load any custom directives
                Directive customDirective = null;
                Map<String, Object> customDirectiveData = new Map<String, Object>();
                if(rawKey.startsWith(DIRECTIVE_SIGN)) {
                    debug('Try getting directive with: ' + rawKey);
                    customDirective = registeredDirectives.get(rawKey.substring(1));
                    Object data = queryData.get(rawKey);
                    if(data instanceof Map<String, Object>) {
                        customDirectiveData = (Map<String, Object>)data;
                    }
                }

                // invoke custom directive before executing
                // there might be more extension points later
                if(customDirective != null) {
                    DirectiveContext context = new DirectiveContext(dataList, queryData, this);
                    debug('beforeExecuting: ' + customDirective.getName());
                    debug('directive args: ' + customDirectiveData);
                    if(!customDirective.beforeExecuting(customDirectiveData, context)) {
                        // reset the result list if the directive explicitly asks for a stop
                        // by returning false
                        debug('skipped executing: ' + customDirective.getName());
                        List<Object> emptyResult = new List<Object>();
                        for(Object dataObj : dataList) {
                            emptyResult.add(new Map<String, Object>());
                        }

                        debug('resultList: ' + emptyResult);
                        debug('--- End Executing ---');
                        return emptyResult;
                    }
                }

                // parse alias and key
                List<String> aliasAndKey = getAliasAndKey(rawKey);
                String alias = aliasAndKey.get(0);
                String key = aliasAndKey.get(1);

                // check if key is defined in the object type
                if(!this.fields.containsKey(key)) {
                    continue;
                }

                debug('field: ' + key);
                debug('alias: ' + alias);
                ObjectTypeField field = this.fields.get(key);

                if(field.resolve == null) {
                    // process fields without resolving
                    debug('process without resolving');
                    for(Integer i = 0; i < dataList.size(); i++) {
                        Map<String, Object> src = (Map<String, Object>)dataList.get(i);
                        Map<String, Object> dest = (Map<String, Object>)resultList.get(i);
                        Object value = src.get(key);
                        // load default values from query data
                        if(value == null) {
                            value = queryData.get(key);
                        }
                        // convert the values according to the data type
                        value = convertValue(value, field.type);
                        dest.put(alias, value);
                    }
                }
                else {
                    // process fields with resolving
                    debug('process with resolving');

                    // create sub query data for the field
                    Map<String, Object> subQueryData = getSubMap(queryData, rawKey);
                    debug('subQueryData: ' + subQueryData);

                    // create arguments for the resolving function
                    Map<String, Object> args = getArgs(field, subQueryData);
                    debug('args: ' + args);

                    // resolving
                    List<Object> resolvedList = null;
                    if(field.resolveBatch) {
                        // batch resolving
                        resolvedList = (List<Object>)field.resolve.run(dataList, args, new ResolvingContext(field.type, subQueryData));
                        // ensure that the result list match the data list
                        if(dataList.size() != resolvedList.size()) {
                            throw new GException('Resolved list should have the same size as data list');
                        }
                    }
                    else {
                        // single resolving
                        resolvedList = new List<Object>();
                        for(Object data : dataList) {
                            resolvedList.add(field.resolve.run(data, args, new ResolvingContext(field.type, subQueryData)));
                        }
                    }
                    debug('resolvedList: ' + resolvedList);

                    // extract object type before executing them on the resolved data
                    ObjectType fieldType = extractObjectType(field.type);
                    Boolean isList = field.type instanceof ListType;
                    Boolean isMap = field.type instanceof MapType;

                    if(fieldType != null) {
                        // executing object type
                        debug('process object type: ' + fieldType);
                        if(isList) {
                            // processing a list of object type
                            debug('process list');

                            // flatten the list so that we can apply batch resolving
                            List<Object> nestedList = (List<Object>)resolvedList;
                            List<Integer> partitionList = new List<Integer>();
                            List<Object> flattenedList = new List<Object>();
                            for(Object childListObj : nestedList) {
                                List<Object> childList = (List<Object>)childListObj;
                                partitionList.add(childList.size());
                                flattenedList.addAll(childList);
                            }

                            List<Object> executedList = fieldType.execute(flattenedList, subQueryData);

                            // restore the list structure
                            List<List<Object>> outputList = new List<List<Object>>();
                            Integer index = 0;
                            for(Integer partition : partitionList) {
                                List<Object> output = new List<Object>();
                                for(Integer i = index; i < index + partition; i++) {
                                    output.add(executedList.get(i));
                                }

                                outputList.add(output);
                                index += partition;
                            }

                            // set back the data
                            for(Integer i = 0; i < outputList.size(); i++) {
                                Object output = outputList.get(i);
                                Map<String, Object> dest = (Map<String, Object>)resultList.get(i);
                                dest.put(alias, output);
                            }
                        }
                        else if(isMap) {
                            // processing a map of object type
                            debug('process map');

                            // flatten the map so that we can apply batch resolving
                            List<Object> nestedList = (List<Object>)resolvedList;
                            List<Integer> partitionList = new List<Integer>();
                            List<Object> flattenedList = new List<Object>();
                            List<String> flattenedKeyList = new List<String>();
                            for(Object childMapObj : nestedList) {
                                Map<String, Object> childMap = (Map<String, Object>)childMapObj;
                                partitionList.add(childMap.size());
                                for(String childKey : childMap.keySet()) {
                                    Object childValue = childMap.get(childKey);
                                    flattenedKeyList.add(childKey);
                                    flattenedList.add(childValue);
                                }
                            }

                            List<Object> executedList = fieldType.execute(flattenedList, subQueryData);

                            // restore the map structure
                            List<Map<String, Object>> outputList = new List<Map<String, Object>>();
                            Integer index = 0;
                            for(Integer partition : partitionList) {
                                Map<String, Object> output = new Map<String, Object>();
                                for(Integer i = index; i < index + partition; i++) {
                                    String flattenedKey = flattenedKeyList.get(i);
                                    Object flattenedValue = executedList.get(i);
                                    output.put(flattenedKey, flattenedValue);
                                }

                                outputList.add(output);
                                index += partition;
                            }

                            // set back the data
                            for(Integer i = 0; i < outputList.size(); i++) {
                                Object output = outputList.get(i);
                                Map<String, Object> dest = (Map<String, Object>)resultList.get(i);
                                dest.put(alias, output);
                            }

                        }
                        else {
                            // processing single object type
                            debug('process single');
                            List<Object> executedList = fieldType.execute(resolvedList, subQueryData);
                            for(Integer i = 0; i < resolvedList.size(); i++) {
                                Object executed = executedList.get(i);
                                Map<String, Object> dest = (Map<String, Object>)resultList.get(i);
                                dest.put(alias, executed);
                            }
                        }
                    }
                    else {
                        // basic data types
                        debug('process non object type');
                        for(Integer i = 0; i < resolvedList.size(); i++) {
                            Object resolved = resolvedList.get(i);
                            Map<String, Object> dest = (Map<String, Object>)resultList.get(i);
                            dest.put(alias, resolved);
                        }
                    }
                }
            }

            debug('resultList: ' + resultList);
            debug('--- End Executing ---');

            return resultList;
        }

        public override String toString() {
            return this.getType() + '[' + this.name + ']';
        }

        /**
         * Return a description of the object type
         *
         * Example:
         * Map<String, Object> description = new G.ObjectType('Book').describe();
         *
         * @return Map<String, Object>
         * */
        public Map<String, Object> describe() {
            Map<String, Object> data = new Map<String, Object>();
            for(ObjectTypeField field : this.fields.values()) {
                Map<String, Object> info = new Map<String, Object>();

                info.put('type', field.type.toString());

                Map<String, String> params = new Map<String, String>();
                for(ObjectTypeParam param : field.params.values()) {
                    params.put(param.name, param.type.toString());
                }
                info.put('params', params);

                data.put(field.name, info);
            }

            return data;
        }
    }

    /**
     * Interface for G.apex Directives
     *
     * Directives are a set of instructions to dynamicall alter the behavior of the query
     * Currently only 'beforeExecuting' extension point is exposed
     * */
    public interface Directive {
        /**
         * Return the name of the directive
         *
         * A name of 'foo' will be used in the query as '#foo'
         *
         * @return String
         * */
        String getName();

        /**
         * Carry out the before executing logic
         * Return false to explicitly stop processing the current node
         *
         * @param args The arguments of the directive
         * @param context The directive context
         * @return Boolean
         * */
        Boolean beforeExecuting(Map<String, Object> args, DirectiveContext context);
    }

    // #include
    private class IncludeDirective implements Directive {
        public String getName() {
            return 'include';
        }

        public Boolean beforeExecuting(Map<String, Object> args, DirectiveContext context) {
            Boolean enabled = (Boolean)R.toBoolean.run(args.get('if'));
            return enabled;
        }
    }

    // #skip
    private class SkipDirective implements Directive {
        public String getName() {
            return 'skip';
        }

        public Boolean beforeExecuting(Map<String, Object> args, DirectiveContext context) {
            Boolean enabled = (Boolean)R.toBoolean.run(args.get('if'));
            return !enabled;
        }
    }

    /**
     * The context for the directive, subject to change in the future
     * */
    public class DirectiveContext {
        /**
         * The current data list being processed
         * */
        public List<Object> dataList;

        /**
         * The current query data
         * */
        public Map<String, Object> queryData;

        /**
         * The current object type
         * */
        public ObjectType currentType;

        /**
         * Construct an instance of the DirectiveContext
         *
         * @param dataList
         * @param queryData
         * @param currentType
         * */
        public DirectiveContext(List<Object> dataList, Map<String, Object> queryData, ObjectType currentType) {
            this.dataList = dataList;
            this.queryData = queryData;
            this.currentType = currentType;
        }
    }

    /**
     * The resolving context for the resolving Funcs
     *
     * ResolvingContexts may help to provide context information for the resolving Funcs
     * to generate the results
     * */
    public class ResolvingContext {
        // Current field type
        private ObjectType currentType;

        // Current query data
        private Map<String, Object> queryData;

        /**
         * Construct an instance of the ResolvingContext
         *
         * @param currentType
         * @param queryData
         * */
        public ResolvingContext(DataType currentType, Map<String, Object> queryData) {
            this.currentType = extractObjectType(currentType);
            this.queryData = queryData;
        }

        /**
         * Get the SObject type
         *
         * Example:
         * String sobjectType = context.getSObjectType();
         *
         * @return String
         * */
        public String getSObjectType() {
            return this.currentType == null ?
                null : G.addNamespace(this.currentType.getSObjectType());
        }

        /**
         * Get the SObject fields, filtered by the query data
         *
         * Example:
         * List<String> fields = context.getSObjectFields();
         * // ('Id', 'Name')
         *
         * @return List<String>
         * */
        public List<String> getSObjectFields() {
            if(this.currentType == null) {
                return new List<String>();
            }

            Map<String, Object> data = this.getQueryData();
            Map<String, String> mapping = this.currentType.getSObjectFieldMapping();
            List<String> fields = new List<String>();
            for(String rawKey : data.keySet()) {
                List<String> aliasAndKey = getAliasAndKey(rawKey);
                String key = aliasAndKey.get(1);
                if(mapping.containsKey(key)) {
                    fields.add(mapping.get(key));
                }
            }

            return fields;
        }

        /**
         * Get the SObject fields mapping
         *
         * Example:
         * Map<String, String> mapping = context.getSObjectFieldMapping();
         * // { 'name' => 'Name' }
         *
         * @return Map<String, String>
         * */
        public Map<String, String> getSObjectFieldMapping() {
            return this.currentType.getSObjectFieldMapping();
        }

        /**
         * Get the current query data, filtering parameters and directives
         *
         * Example:
         * Map<String, Object> queryData = context.getQueryData();
         *
         * @return Map<String, Object>
         * */
        public Map<String, Object> getQueryData() {
            Map<String, Object> data = new Map<String, Object>();
            for(String key : this.queryData.keySet()) {
                if(key.startsWith(PARAMETER_SIGN) || key.startsWith(DIRECTIVE_SIGN)) {
                    continue;
                }

                data.put(key, this.queryData.get(key));
            }

            return data;
        }

        /**
         * Convert the SObject to a map required by the object type
         *
         * Example:
         * Book__c book = // query
         * Map<String, Object> data = context.convertSObject(book);
         *
         * @param so The SObject
         * @return Map<String, Object>
         * */
        public Map<String, Object> convertSObject(SObject so) {
            return convertObject(so);
        }

        /**
         * Convert the object to a map required by the object type
         *
         * Example:
         * MyCustomObject obj = // query
         * Map<String, Object> data = context.convertSObject(obj);
         *
         * @param obj The object
         * @return Map<String, Object>
         * */
        public Map<String, Object> convertObject(Object obj) {
            Map<String, Object> result = new Map<String, Object>();
            Map<String, String> mapping = this.currentType.getSObjectFieldMapping();
            Map<String, Object> fields =
                (obj instanceOf SObject) ?
                ((SObject)obj).getPopulatedFieldsAsMap() :
                (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));

            for(String key : mapping.keySet()) {
                String field = mapping.get(key);
                Object value = R.path.run(field, fields);
                if(value != null) {
                    result.put(key, value);
                }
            }

            return result;
        }
    }

    // The object type field
    private class ObjectTypeField {
        // The field name
        public String name;

        // The field type
        public DataType type;

        // The field resolve Func
        public Func resolve;

        // Whether to resolve in batch
        public Boolean resolveBatch;

        // The SObject field bound
        public String sObjectField;

        // The attached parameters
        public Map<String, ObjectTypeParam> params = new Map<String, ObjectTypeParam>();

        // Construct an instance of ObjectTypeField
        public ObjectTypeField(String name, DataType type, Func resolve, Boolean resolveBatch, String sObjectField) {
            this.name = name;
            this.type = type;
            this.resolve = resolve;
            this.resolveBatch = resolveBatch;
            this.sObjectField = sObjectField;
        }
    }

    // The object type parameters
    private class ObjectTypeParam {
        // The parameter name
        public String name;

        // The parameter data type
        public DataType type;

        // The validation Func
        public Func validate;

        // Construct an instance of ObjectTypeParam
        public ObjectTypeParam(String name, DataType type, Func validate) {
            this.name = name;
            this.type = type;
            this.validate = validate;
        }
    }

    /**
     * The Reference DataType, which acts as a placeholder for the DataTypes currently
     * undefined, or not available
     * */
    public class ReferenceType extends DataType {
        private String name;

        /**
         * Construct a ReferenceType by the name
         *
         * @param name The object type name
         * */
        public ReferenceType(String name) {
            super(TYPE_REFERENCE);

            if(name == null) {
                throw new GException('Reference type name is required');
            }
            this.name = name;
        }

        /**
         * Get the object type name
         *
         * @return String
         * */
        public String getName() {
            return this.name;
        }

        /**
         * Get the referenced object type
         *
         * @return ObjectType
         * */
        public ObjectType getReferencedType() {
            return getObjectType(this.name);
        }

        public override String toString() {
            return this.getType() + '[' + this.name + ']';
        }
    }

    /**
     * The collection of root object types defined in G.apex
     *
     * At one time, there can only be one instance of Schema available globally
     * */
    public class Schema {
        // Registered root object types
        private Map<String, ObjectType> objectTypes = new Map<String, ObjectType>();

        public Schema() {
            registeredSchema = this;
        }

        /**
         * Add a root object type
         *
         * Example:
         * new G.Schema()
         *     .add(new G.ObjectType('Book'));
         *
         * @param type The object type
         * @return Schema
         * */
        public Schema add(ObjectType type) {
            this.objectTypes.put(type.getName(), type);

            return this;
        }

        // Extract fragments from the query data
        private Map<String, Object> extractFragments(Map<String, Object> queryData) {
            // Fragments can only be defined at the root of the schema
            Map<String, Object> fragments = new Map<String, Object>();
            for(String key : queryData.keySet()) {
                if(key.startsWith(FRAGMENT_SIGN)) {
                    fragments.put(key, queryData.get(key));
                    queryData.remove(key);
                }
            }

            debug('Extracted fragments: ' + fragments);

            return fragments;
        }

        // Extract variables from the query data
        private Map<String, String> extractVariables(Map<String, Object> queryData) {
            // Variables can only be defined at the root of the schema
            Map<String, String> variables = new Map<String, String>();
            for(String key : queryData.keySet()) {
                if(key.startsWith(VARIABLE_SIGN)) {
                    variables.put(key, String.valueOf(queryData.get(key)));
                    queryData.remove(key);
                }
            }

            debug('Extracted variables: ' + variables);

            return variables;
        }

        // Replace variables
        private Map<String, Object> replaceVariables(Map<String, Object> queryData, Map<String, String> variables) {
            debug('Before replacing variables: ' + queryData);

            String jsonData = JSON.serialize(queryData);
            for(String variableName : variables.keySet()) {
                String variableValue = variables.get(variableName);
                jsonData = jsonData.replaceAll('\\' + variableName, variableValue);
            }

            Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(jsonData);

            debug('After replacing variables: ' + result);

            return result;
        }

        // Put the definition of the fragment into the query data
        private void expandQueryData(Map<String, Object> queryData, Map<String, Object> fragments) {
            debug('Before expand: ' + queryData);

            for(String key : queryData.keySet()) {
                Object value = queryData.get(key);
                if(fragments.containsKey(key)) {
                    Object fragmentValue = fragments.get(key);
                    if(fragmentValue instanceof Map<String, Object>) {
                        Map<String, Object> fragment = (Map<String, Object>)fragmentValue;
                        queryData.put(key, fragment);
                    }
                }

                value = queryData.get(key);
                if(value instanceof Map<String, Object>) {
                    expandQueryData((Map<String, Object>)value, fragments);
                }
            }

            debug('After expand: ' + queryData);
        }

        // Remove extra fragment key nodes
        private Map<String, Object> cleanUpQueryData(Map<String, Object> queryData) {
            debug('Before Cleanup: ' + queryData);

            Map<String, Object> result = new Map<String, Object>();
            for(String key : queryData.keySet()) {
                Object child = queryData.get(key);
                if(child instanceof Map<String, Object>) {
                    Map<String, Object> childMap = (Map<String, Object>)child;
                    if(key.startsWith(FRAGMENT_SIGN)) {
                        Map<String, Object> cleanedChildMap = cleanUpQueryData(childMap);

                        for(String childKey : cleanedChildMap.keySet()) {
                            result.put(childKey, cleanedChildMap.get(childKey));
                        }
                    }
                    else {
                        result.put(key, cleanUpQueryData(childMap));
                    }
                }
                else {
                    result.put(key, child);
                }
            }

            debug('After Cleanup: ' + result);

            return result;
        }

        /**
         * Execute the schema
         * Mainly used by G.execute
         *
         * @param queryData
         * @return Object
         * */
        public Object execute(Map<String, Object> queryData) {
            debug('**** Begin Executing Schema ****');
            Map<String, Object> result = new Map<String, Object>();

            // Process Variables
            Map<String, String> variables = extractVariables(queryData);
            queryData = replaceVariables(queryData, variables);

            // Process Fragments
            Map<String, Object> fragments = extractFragments(queryData);
            expandQueryData(queryData, fragments);
            queryData = cleanUpQueryData(queryData);

            for(String key : queryData.keySet()) {
                Object value = queryData.get(key);
                if(value instanceof Map<String, Object>) {
                    ObjectType type = this.objectTypes.get(key);
                    if(type != null) {
                        // Process root object type
                        debug('Execute object type under schema: ' + key);
                        List<Map<String, Object>> dataList = new List<Map<String, Object>>();
                        Map<String, Object> data = new Map<String, Object>();
                        dataList.add(data);
                        List<Object> resultList = type.execute(dataList, (Map<String, Object>)value);
                        result.put(key, resultList.get(0));
                    }
                }
            }

            debug('Final result: ' + result);
            debug('**** End Executing Schema ****');
            return result;
        }

        /**
         * Describe the schema
         *
         * Example:
         * Map<String, String> data = new G.Schema.describe();
         * // { 'query' => 'Query' }
         *
         * @return Map<String, String>
         * */
        public Map<String, String> describe() {
            Map<String, String> data = new Map<String, String>();
            for(ObjectType type : this.objectTypes.values()) {
                data.put(type.getName(), type.toString());
            }

            return data;
        }
    }

    /**
     * Interface for batch resolving
     * An alternative to the resolving Func
     * */
    public interface BatchResolver {
        /**
         * Resolve the field value
         *
         * @param parents The parent data nodes
         * @param args The arguments of the resolving function
         * @param context The resolving context
         * @return List<Object>
         * */
        List<Object> resolve(List<Object> parents, Map<String, Object> args, ResolvingContext context);
    }

    /**
     * Interface for resolving
     * An alternative to the resolving Func
     * */
    public interface Resolver {
        /**
         * Resolve the field value
         *
         * @param parent The parent data node
         * @param args The arguments of the resolving function
         * @param context The resolving context
         * @return Object
         * */
        Object resolve(Map<String, Object> parent, Map<String, Object> args, ResolvingContext context);
    }

    // Wrapper Func for BatchResolver
    private class BatchResolverFunc extends Func {
        private BatchResolver resolver;

        public BatchResolverFunc(BatchResolver resolver) {
            super(3);
            this.resolver = resolver;
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            List<Object> parents = (List<Object>)arg1;
            Map<String, Object> args = (Map<String, Object>)arg2;
            ResolvingContext context = (ResolvingContext)arg3;

            return this.resolver.resolve(parents, args, context);
        }
    }

    // Wrapper Func for Resolver
    private class ResolverFunc extends Func {
        private Resolver resolver;

        public ResolverFunc(Resolver resolver) {
            super(3);
            this.resolver = resolver;
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            Map<String, Object> parent = (Map<String, Object>)arg1;
            Map<String, Object> args = (Map<String, Object>)arg2;
            ResolvingContext context = (ResolvingContext)arg3;

            return this.resolver.resolve(parent, args, context);
        }
    }

    private class AddNamespaceFunc extends Func {
        public AddNamespaceFunc() {
            super(1);
        }

        public override Object exec(Object arg) {
            String str = (String)arg;

            return addNamespace(str);
        }
    }

    private static String addNamespace(String src) {
        if (src != null && src.countMatches('__') == 1) {
            src = namespace + src;
        }

        return src;
    }

    private static String namespace {
        get {
            final String className = G.class.getName();
            final List<String> nameSplit = className.split('\\.');

            if (nameSplit.size() > 1) {
                return nameSplit.get(0) + '__';
            } else {
                return '';
            }
        }
    }

    public class GException extends Exception {
    }
}
