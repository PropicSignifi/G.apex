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
public class GDemoController {
    private static Map<String, Object> book1 = new Map<String, Object>{
        'id' => '1',
        'name' => 'First Book',
        'authorId' => '1'
    };

    private static Map<String, Object> book2 = new Map<String, Object>{
        'id' => '2',
        'name' => 'Second Book',
        'authorId' => '1'
    };

    private static Map<String, Object> book3 = new Map<String, Object>{
        'id' => '3',
        'name' => 'Third Book',
        'authorId' => '2'
    };

    private static List<Map<String, Object>> books = new List<Map<String, Object>>{
        book1,
        book2,
        book3
    };

    private static Map<String, Object> author1 = new Map<String, Object>{
        'id' => '1',
        'name' => 'First Author'
    };

    private static Map<String, Object> author2 = new Map<String, Object>{
        'id' => '2',
        'name' => 'Second Author'
    };

    private static List<Map<String, Object>> authors = new List<Map<String, Object>>{
        author1,
        author2
    };

    private static G.ObjectType bookType = new G.ObjectType('Book', 'Book__c')
        .addField('id', G.StringType, 'Id')
        .addField('name', G.StringType, 'Name')
        .addField('author', new G.ReferenceType('Author'), new BookAuthorResolver());

    private static G.ObjectType authorType = new G.ObjectType('Author')
        .addField('id', G.StringType)
        .addField('name', G.StringType)
        .addField('books', new G.ListType(new G.ReferenceType('Book')), new AuthorBooksResolver());

    private static G.Schema schema = new G.Schema()
        .add(
            new G.ObjectType('query')
                .addField('books', new G.ListType(bookType), R.constant.apply(new List<Object>{ books }))
                .addField('book', bookType, new GetBookResolver())
                    .addParam('book', 'id', G.StringType, R.isNotNull)
                .addField('authors', new G.ListType(authorType), R.constant.apply(new List<Object>{ authors }))
                .addField('author', authorType, new GetAuthorResolver())
                    .addParam('author', 'id', G.StringType, R.isNotNull)
        );

    private class BookAuthorResolver implements G.Resolver {
        public Object resolve(Map<String, Object> parent, Map<String, Object> args, G.ResolvingContext context) {
            return R.of(authors).find(R.propEq.apply('id', parent.get('authorId'))).toMap();
        }
    }

    private class AuthorBooksResolver implements G.BatchResolver {
        public List<Object> resolve(List<Object> parents, Map<String, Object> args, G.ResolvingContext context) {
            List<Object> result = new List<Object>();

            for(Object parentObj : parents) {
                Map<String, Object> parent = (Map<String, Object>)parentObj;
                List<Object> found = R.of(books).filter(R.propEq.apply('authorId', parent.get('id'))).toList();
                result.add(found);
            }

            return result;
        }
    }

    private class GetAuthorResolver implements G.Resolver {
        public Object resolve(Map<String, Object> parent, Map<String, Object> args, G.ResolvingContext context) {
            return R.of(authors).find(R.propEq.apply('id', args.get('id'))).toMap();
        }
    }

    private class GetBookResolver implements G.Resolver {
        public Object resolve(Map<String, Object> parent, Map<String, Object> args, G.ResolvingContext context) {
            return R.of(books).find(R.propEq.apply('id', args.get('id'))).toMap();
        }
    }

    @AuraEnabled
    public static Map<String, Object> describe(String type) {
        try {
            return G.describe(type);
        }
        catch(Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> execute(String query) {
        try {
            return (Map<String, Object>)G.execute(query);
        }
        catch(Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }
}
