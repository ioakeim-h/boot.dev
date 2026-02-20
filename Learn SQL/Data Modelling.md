# Data Modelling

Data modelling occurs across **three stages**

1. Conceptual = big picture
   
    ```
    Conceptual schemas offer a big-picture view of what the system will contain, how it will be organized, and which business rules are involved. 
    Conceptual models are usually created as part of the process of gathering initial project requirements.
    ```

2. Logical = detailed design
   
    ```
    Logical database schemas are less abstract, compared to conceptual schemas. 
    They clearly define schema objects with information, such as table names, field names, entity relationships, and integrity constraints — i.e. any rules that govern the database. 
    However, they do not typically include any technical requirements.
    ```

3. Physical = actual implementation

    ```
    Physical database schemas provide the technical information that the logical database schema type lacks in addition to the contextual information, such as table names, field names, entity relationships, et cetera. 
    That is, it also includes the syntax that will be used to create these data structures within disk storage.
    ```

The entire idea is that the physical database is built after the blueprint is validated, so you don’t “dig into construction” before knowing what works. By modelling first, you spot design flaws early, decide on normalization vs denormalization, plan for query patterns and reporting needs, and avoid costly changes later which are 99.99% guaranteed.

## Conceptual

### Choose a Desgin

The conceptual stage is usually where we decide the database design.
- Go OLTP if the system runs daily operations — many users creating or updating individual records, requiring fast, reliable transactions (orders, payments, bookings, user actions).
- Go OLAP if the system is mainly for analysis — reading large amounts of historical data, aggregations, reports, or dashboards.

### Visualize (High-Level)

Once we’ve picked the database design that makes the most sense for what we’re building, the next step is to think through the actual shape of our data — what we’re storing, how it’s organized, and the business rules that tie everything together. To get there, we really just need to answer two simple questions:
1. What are they key concepts in our business?
2. How do they relate to one another?

These key concepts ultimately become the entities in our database. But how do we know when something qualifies as an entity? In general, an entity should meet three criteria:

**Identifying an Entity**

1. It represents a person, place, thing, event, or concept <br>
*Example:* A Customer is a person your business interacts with.

2. It can be uniquely identified <br>
*Example:* Each Order has a unique order number that distinguishes it from all others.

3. It has attributes that describe it <br>
*Example:* A Product has attributes like name, price, and SKU

From here, the entities we’ve uncovered, along with the relationships between them, can be laid out visually in an Entity Relationship Diagram (ERD). At the conceptual stage, an ERD captures only the entities and their relationships, which are typically shown using [Crow’s Foot notation](https://www.red-gate.com/blog/crow-s-foot-notation). There are plenty of tools that can help you sketch ERDs:
- Simple, quick, free, but limited relationship types: [Visual Paradigm](https://online.visual-paradigm.com/diagrams/solutions/free-erd-tool/)
- Simple enough, free, more features, automatically generates SQL code from your ERD: [drawDB](https://www.drawdb.app/)

**ERD Example: Library Borrowing**

Imagine a tiny library system with just four core concepts: Book, Author, Member and Loan <br>
From these, we can define the relationships:
- A Member can have zero or many Loans.
- A Book can appear in zero or many Loans.
- Each Loan links exactly one Member to exactly one Book.
- A Book can have one or many Authors (not supported by Visual Paradigm), and an Author can write zero or many Books.  

![conceptual data modelling](images/conceptual_data_modelling_example.png)

**Loan is the mediator between `Member` and `Book`.** Although a member can be associated with a book, drawing a direct relationship between `Member` and `Book` would incorrectly suggest an inherent connection between them outside of borrowing.  To reflect the real‑world process, members are linked to books only through the `Loan` entity, which represents the borrowing event itself.

## Logical

By now we’ve figured out the main entities and how they relate. That gives us the big picture. Next, we start adding the structure and detail that turns this into something a developer can actually build. This is where we shift into the logical stage and shape the model into a clearer, more concrete blueprint.

Several of the procedures in the logical stage overlap with what we did in the conceptual stage, so it might seem like the logical model simply adds detail to the structure we already identified. In reality, that’s not how it works. In OLTP, normalization can split entities into multiple tables and introduce new relationships. In OLAP, the entities we identified earlier must be reorganized into fact and dimension tables and fitted into schemas such as star or snowflake. So yes, the logical stage adds detail — but it also forces us to re‑iterate on the structure we defined conceptually.

### OLTP Workflow

| Step                          | Description                                                                 | Examples / Notes                                                                                                      |
|-------------------------------|-----------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------|
| Identify entities             | Determine the core business objects the system manages                      | • The system tracks **Customers**, **Orders**, **Products**, and **Payments**.<br>• These represent the primary nouns in the domain. |
| Define attributes             | List the essential fields that describe each entity                         | • An **Order** typically includes fields such as `order_id`, `order_date`, `customer_id`, and `total_amount`.<br>• Attributes should fully describe the entity without redundancy. |
| Define primary keys           | Establish strong, unique identifiers                        | • Choose between **natural keys** (e.g., email for Customer) and **surrogate keys** (e.g., auto‑increment IDs).<br>• Use **composite keys** when the business logic requires multi‑column uniqueness.<br>• Ensure keys align with business rules for uniqueness. |
| Define relationships          | Specify how entities connect and depend on each other                       | • A **Customer** can have many **Orders** (one‑to‑many).<br>• **Products** and **Orders** form a many‑to‑many relationship via **OrderItems**.<br>• Identify whether relationships are **optional** (e.g., a Customer may have zero Orders) or **mandatory** (an Order must belong to a Customer). |
| Define normalization requirements | Decide how to reduce redundancy and avoid anomalies                     | • Apply normalization to split large or repetitive tables into smaller, well‑structured ones.<br>• Remove repeating groups and duplicated data to avoid update anomalies.<br>• Choose the appropriate normalization level (often 3NF for OLTP). |
| Define integrity rules        | Identify constraints that guarantee valid, consistent data                  | • Specify which fields can be **NULL** and which must always have a value.<br>• Add **unique constraints** (e.g., SKU must be unique).<br>• Enforce **foreign keys** to maintain referential integrity.<br>• Apply business rules such as “an order must contain at least one order item.” |
| Define transaction boundaries | Determine what counts as a single atomic operation                          | • Identify which updates must occur together, such as inserting an Order and its OrderItems in one transaction.<br>• Ensure operations follow **ACID** principles to maintain consistency. |


### OLAP Workflow

| Step                          | Description                                                                 | Examples / Notes                                                                                                      |
|-------------------------------|-----------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------|
| Identify facts                | Determine the core analytical processes the warehouse must support          | • Common fact domains include **sales**, **inventory movements**, **website activity**, and **financial transactions**.<br>• These processes become **fact tables** that store measurable events. |
| Identify dimensions           | Define descriptive entities that provide context for analysis               | • Typical dimensions include **Customer**, **Product**, **Date**, **Store**, **Region**.<br>• Dimensions answer the “who, what, when, where” of each fact. |
| Define grain                  | Specify the level of detail represented by each row in a fact table        | • Examples of grain: **one row per order line**, **one row per inventory movement**, **one row per daily snapshot**.<br>• Measures stored at that grain may include **quantity**, **revenue**, **cost**, **click count**, etc.<br>• Grain is the most critical OLAP decision: too fine → massive tables; too coarse → loss of analytical value.<br>• Ask: **What does one row in this fact table represent?** |
| Choose schema structure       | Select the dimensional modeling pattern                                    | • **Star schema:** fact tables + denormalized dimensions (most common).<br>• **Snowflake schema:** dimensions normalized into sub‑dimensions.<br>• **Wide denormalized tables:** often used in modern columnar engines for performance. |
| Define hierarchies and drill paths | Organize dimension attributes from most detailed to most general      | • **Date:** Day → Month → Quarter → Year.<br>• **Product:** SKU → Category → Department.<br>• **Store:** Store → Region → Country.<br>• These hierarchies support drill‑down and roll‑up analysis. |
| Establish relationships       | Define how facts connect to dimensions                                     | • Use **surrogate keys** for dimensions to ensure stable identifiers.<br>• Fact tables contain **foreign keys** referencing dimension tables.<br>• Relationships are typically **many‑to‑one** from fact to dimension. |
| Plan for slowly changing dimensions | Decide how to handle changes in dimension attributes over time       | • **Type 1:** Overwrite old values (no history).<br>• **Type 2:** Add new rows to preserve full history (most common).<br>• **Type 3:** Store limited history using additional columns. |

### Visualize (Low-Level)

At the logical stage, the model stops being purely descriptive and starts becoming actionable. This is where business entities turn into actual tables that a database can implement. <br>
To do that, we answer concrete design questions such as:
- What tables do we need?
- What columns belong in each table?
- What data type should each column use?
- Which column uniquely identifies each row (the primary key)?
- How do we connect tables using keys and relationships?

**Constraints play a key role here** — they ensure the logical model captures real business rules, not just structural relationships. 

Also, this is the point where we should add any **junction tables**. Relational databases cannot store a many‑to‑many relationship directly, so we must break the many‑to‑many into two one‑to‑many relationships using a junction table.

**ERD Example: Library Borrowing (Extended)**

We've added columns, constraints, data types and a junction table. By reading the ERD, we can see that:
- A member can have many loans (linked via member_id)
- A book can be in many loans over time
- A book can appear in many BookAuthor rows
- An Author can appear in many BookAuthor rows
- Each BookAuthor row links one Book to one Author

![logical data modelling example](images/logical_data_modelling_example.png)

**Why isn’t `Loan` → `Book` a many‑to‑one?** Because a loan represents one borrowing event for one book. If we allowed a single loan to contain multiple books, then returning one book but not the others becomes messy:
- due dates might differ
- fines might differ
- availability tracking becomes harder

So the simplest, cleanest model is: `One loan = one book borrowed by one member at one time` <br>
If someone borrows 3 books, we create 3 loan rows.

This keeps the model consistent and avoids hidden complexity.

### Documentation

The logical model is strengthened by thorough documentation, which provides the level of detail needed for accurate implementation. Artifacts such as a data dictionary, a business glossary, and a relationship matrix help clarify the structure, meaning, and interactions within the data model.

**Data Dictionary: a structured description of every table and column** 
- Table name
- Column name
- Data type (and length)
- Nullability requirements
- Business descritpion in plain language
- Allowed values
- Example values

![data dictionary example](images/data%20dictionary.png)

**Business Rule Catalog: what the business allows and forbids**
- Rule description
- Tables involved
- Columns involved
- How the rule is enforced

![business rule catalog example](images/business%20rule%20catalog.png)

**Relationshp Matrix: a description of relationships**
- Parent table
- Parent key
- Child table
- Child table's foreign key
- Cardinality
- Business meaning of the relationship

![relationship matrix example](images/relationship%20matrix.png)










OLAP workflow additions: (1) Identify conformed dimensions, (2) think abou SCD upfront, (3) Test queries to ensure an accurate model