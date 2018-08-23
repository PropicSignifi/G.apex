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
@isTest
private class GTest {
    private static Map<String, Object> book = new Map<String, Object>{
        'id' => '1',
        'name' => 'First Book',
        'number' => null
    };

    private static List<Map<String, Object>> books = new List<Map<String, Object>>{
        book
    };

    private static Map<String, Object> author = new Map<String, Object>{
        'id' => '1',
        'name' => 'First Author'
    };

    private static List<Map<String, Object>> authors = new List<Map<String, Object>>{
        author
    };

    private static G.ObjectType bookType = new G.ObjectType('Book', 'Book__c')
        .addField('id', G.StringType, 'Id')
        .addField('name', G.StringType, 'Name')
        .addField('number', G.IntegerType)
        .addField('author', new G.ReferenceType('Author'), R.constant.apply(new List<Object>{ author }))
        .addField('meta', new G.MapType(new G.ReferenceType('Author')), R.constant.apply(new List<Object>{ new Map<String, Object>{ 'a' => author } }));

    private static G.ObjectType authorType = new G.ObjectType('Author')
        .addField('id', G.StringType)
        .addField('name', G.StringType)
        .addField('books', new G.ListType(new G.ReferenceType('Book')), R.constant.apply(new List<Object>{ books }));

    private static G.Schema schema = new G.Schema()
        .add(
            new G.ObjectType('query')
                .addField('books', new G.ListType(bookType), R.constant.apply(new List<Object>{ books }))
                .addField('book', bookType, R.constant.apply(new List<Object>{ book }))
                .addField('authors', new G.ListType(authorType), R.constant.apply(new List<Object>{ authors }))
                .addField('author', authorType, R.constant.apply(new List<Object>{ author }))
                .addField('echo', G.StringType, new EchoFunc())
                    .addParam('echo', 'msg', G.StringType, R.isNotNull)
                .addField('echoSingle', G.StringType, new EchoSingleResolver())
                    .addParam('echoSingle', 'msg', G.StringType, R.isNotNull)
        );

    private class EchoFunc extends Func {
        public EchoFunc() {
            super(3);
        }

        public override Object exec(Object arg1, Object arg2, Object arg3) {
            List<Object> parents = (List<Object>)arg1;
            Map<String, Object> args = (Map<String, Object>)arg2;
            G.ResolvingContext context = (G.ResolvingContext)arg3;

            String soql = 'SELECT ' + String.join(context.getSObjectFields(), ', ') + ' FROM ' + context.getSObjectType();

            List<Object> result = new List<Object>();
            for(Object p : parents) {
                result.add(args.get('msg'));
            }

            return result;
        }
    }

    private class EchoSingleResolver implements G.Resolver {
        public Object resolve(Map<String, Object> parent, Map<String, Object> args, G.ResolvingContext context) {
            return args.get('msg');
        }
    }

    @isTest
    private static void testSingle() {
        Map<String, Object> queryData = new Map<String, Object>{
            'query' => new Map<String, Object>{
                'book' => new Map<String, Object>{
                    'name' => ''
                }
            }
        };

        Map<String, Object> data = (Map<String, Object>)G.execute(schema, queryData);

        Map<String, Object> expected = new Map<String, Object>{
            'query' => new Map<String, Object>{
                'book' => new Map<String, Object> {
                    'name' => 'First Book'
                }
            }
        };

        System.assertEquals(expected, data);
    }

    @isTest
    private static void testList() {
        Map<String, Object> queryData = new Map<String, Object>{
            'query' => new Map<String, Object>{
                'books' => new Map<String, Object>{
                    'name' => ''
                }
            }
        };

        Map<String, Object> data = (Map<String, Object>)G.execute(schema, queryData);

        Map<String, Object> expected = new Map<String, Object>{
            'query' => new Map<String, Object>{
                'books' => new List<Object>{
                    new Map<String, Object> {
                        'name' => 'First Book'
                    }
                }
            }
        };

        System.assertEquals(expected, data);
    }

    @isTest
    private static void testMap() {
        Map<String, Object> queryData = new Map<String, Object>{
            'query' => new Map<String, Object>{
                'book' => new Map<String, Object>{
                    'meta' => new Map<String, Object>{
                        'name' => ''
                    }
                }
            }
        };

        Map<String, Object> data = (Map<String, Object>)G.execute(schema, queryData);

        Map<String, Object> expected = new Map<String, Object>{
            'query' => new Map<String, Object>{
                'book' => new Map<String, Object>{
                    'meta' => new Map<String, Object>{
                        'a' => new Map<String, Object>{
                            'name' => 'First Author'
                        }
                    }
                }
            }
        };

        System.assertEquals(expected, data);
    }

    @isTest
    private static void testReferenceSingle() {
        Map<String, Object> queryData = new Map<String, Object>{
            'query' => new Map<String, Object>{
                'book' => new Map<String, Object>{
                    'author' => new Map<String, Object>{
                        'name' => ''
                    }
                }
            }
        };

        Map<String, Object> data = (Map<String, Object>)G.execute(schema, queryData);

        Map<String, Object> expected = new Map<String, Object>{
            'query' => new Map<String, Object>{
                'book' => new Map<String, Object>{
                    'author' => new Map<String, Object>{
                        'name' => 'First Author'
                    }
                }
            }
        };

        System.assertEquals(expected, data);
    }

    @isTest
    private static void testReferenceList() {
        Map<String, Object> queryData = new Map<String, Object>{
            'query' => new Map<String, Object>{
                'author' => new Map<String, Object>{
                    'books' => new Map<String, Object>{
                        'name' => ''
                    }
                }
            }
        };

        Map<String, Object> data = (Map<String, Object>)G.execute(schema, queryData);

        Map<String, Object> expected = new Map<String, Object>{
            'query' => new Map<String, Object>{
                'author' => new Map<String, Object>{
                    'books' => new List<Object>{
                        new Map<String, Object>{
                            'name' => 'First Book'
                        }
                    }
                }
            }
        };

        System.assertEquals(expected, data);
    }

    @isTest
    private static void testArgs() {
        Map<String, Object> queryData = new Map<String, Object>{
            'query' => new Map<String, Object>{
                'echo' => new Map<String, Object>{
                    '@msg' => 'abc'
                }
            }
        };

        Map<String, Object> data = (Map<String, Object>)G.execute(schema, queryData);

        Map<String, Object> expected = new Map<String, Object>{
            'query' => new Map<String, Object>{
                'echo' => 'abc'
            }
        };

        System.assertEquals(expected, data);
    }

    @isTest
    private static void testValidation() {
        Map<String, Object> queryData = new Map<String, Object>{
            'query' => new Map<String, Object>{
                'echo' => new Map<String, Object>{
                    '@msg' => null
                }
            }
        };

        try {
            Map<String, Object> data = (Map<String, Object>)G.execute(schema, queryData);
            System.assert(false);
        }
        catch(Exception e) {
            System.assert(true);
        }
    }

    @isTest
    private static void testResolveSingle() {
        String query = '{' +
            '"query": {' +
                '"echoSingle": {' +
                    '"@msg": "abc"' +
                '}' +
            '}' +
        '}';

        Map<String, Object> data = (Map<String, Object>)G.execute(query);

        Map<String, Object> expected = new Map<String, Object>{
            'query' => new Map<String, Object>{
                'echoSingle' => 'abc'
            }
        };

        System.assertEquals(expected, data);
    }

    @isTest
    private static void testSObjectFieldBinding() {
        G.ObjectType type = G.getObjectType('Book');

        System.assertEquals('Book__c', type.getSObjectType());
        System.assertEquals(new Map<String, String>{
            'id' => 'Id',
            'name' => 'Name'
        }, type.getSObjectFieldMapping());
    }

    @isTest
    private static void testToJSON() {
        System.assert(G.describe(null) != null);
        System.assert(G.describe('Book') != null);
    }

    @isTest
    private static void testDefaultValue() {
        String query = '{' +
            '"query": {' +
                '"book": {' +
                    '"name": "",' +
                    '"number": "3"' +
                '}' +
            '}' +
        '}';

        Map<String, Object> data = (Map<String, Object>)G.execute(query);

        Map<String, Object> expected = new Map<String, Object>{
            'query' => new Map<String, Object>{
                'book' => new Map<String, Object>{
                    'name' => 'First Book',
                    'number' => 3
                }
            }
        };

        System.assertEquals(expected, data);
    }

    @isTest
    private static void testAlias() {
        String query = '{' +
            '"query": {' +
                '"mybook:book": {' +
                    '"myname:name": ""' +
                '}' +
            '}' +
        '}';

        Map<String, Object> data = (Map<String, Object>)G.execute(query);

        Map<String, Object> expected = new Map<String, Object>{
            'query' => new Map<String, Object>{
                'mybook' => new Map<String, Object>{
                    'myname' => 'First Book'
                }
            }
        };

        System.assertEquals(expected, data);
    }

    @isTest
    private static void testFragment() {
        String query = '{' +
            '"query": {' +
                '"book": {' +
                    '"...sum": ""' +
                '}' +
            '},' +
            '"...sum": {' +
                '"...name": ""' +
            '},' +
            '"...name": {' +
                '"name": ""' +
            '}' +
        '}';

        Map<String, Object> data = (Map<String, Object>)G.execute(query);

        Map<String, Object> expected = new Map<String, Object>{
            'query' => new Map<String, Object>{
                'book' => new Map<String, Object>{
                    'name' => 'First Book'
                }
            }
        };

        System.assertEquals(expected, data);
    }

    @isTest
    private static void testVariable() {
        String query = '{' +
            '"query": {' +
                '"book": {' +
                    '"$name": ""' +
                '}' +
            '},' +
            '"$name": "name"' +
        '}';

        Map<String, Object> data = (Map<String, Object>)G.execute(query);

        Map<String, Object> expected = new Map<String, Object>{
            'query' => new Map<String, Object>{
                'book' => new Map<String, Object>{
                    'name' => 'First Book'
                }
            }
        };

        System.assertEquals(expected, data);
    }
}
