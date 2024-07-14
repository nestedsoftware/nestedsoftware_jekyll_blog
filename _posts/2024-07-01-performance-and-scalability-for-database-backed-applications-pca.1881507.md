---
title: Performance and Scalability for Database-Backed Applications
published: true
description: Lessons learneda about improving performance of database-backed applications
tags: database, sql, performance, scalability
cover_image: /assets/images/2024-07-01-performance-and-scalability-for-database-backed-applications-pca.1881507/cdp0f109wcggtuacvs9t.png
---

The following are some techniques that I've found to be both useful and practical over the years for scaling data-intensive applications.

# Split Large Jobs into Smaller Parallel Jobs

When processing large amounts of data, a very useful technique to improve performance is to break up a given job into smaller jobs that can run in parallel. Once all of the jobs have completed, the partial results can be integrated together. 

Keep in mind that when the parallel jobs are hitting the same database, locking can become a bottleneck. Also, this approach requires that you be wary of over-taxing the database, since all of these sessions will be running concurrently.

For very high scalability, this type of idea can be implemented with tools like [MapReduce](https://www.talend.com/resources/what-is-mapreduce).

# Pre-fetch Data Before Processing

I/O latency is a common cause of performance obstacles. Replacing multiple calls to the database with a single call is often helpful. 

Here you would pre-load data from the database and cache it in memory. That way the data can be used/reused without requiring separate round trips to the database.

It's important to keep in mind the possibility that the cached data may be updated during processing, which may or may not have ramifications for the given use case.

Storing large amounts of data in RAM also increases the resource usage of the application, so it's important to consider the tradeoffs between performance and memory usage.

# Batch Multiple SQL Executions into a Single Call

Consider a batch data import job. The job may repeatedly execute SQL statements to persist data in a loop. You can instead collect a certain amount of data within the application, and issue a single SQL call to the database. This again reduces the amount of I/O required. 

One issue with this approach is that a single failure will cause the entire transaction to rollback. When a batch fails, you can re-run each item in that batch again one at a time so that the rest of the data can still be persisted, and only the failing records will produce an error.

> Note: If you're sending individual SQL statements in a loop, you can also set the database commit frequency so as to commit in batches rather than for each individual row.

# Optimize SQL Queries

Working with relational databases can be somewhat of an art form. When queries perform poorly, it can be helpful to deeply understand the execution plan used by the database engine and to improve the SQL based on that information. 

Rewriting inefficient SQL queries as well as reviewing indexes associated with the tables in the query can help to improve performance. In Oracle, one can add database hints to help improve queries, though personally I prefer to avoid that as much as possible.

# Use Separate Databases/Schemas

Having a single large database can be convenient, but it also can introduce performance problems when there are huge numbers of rows in important tables. For example, let's say a b2b enterprise application is used by many different companies. Having a separate database or schema for each company can significantly improve performance. 

Such partitioning also makes it easier to maintain security so that a company's data won't be accidentally accessed by the wrong users.

> When data is broken up across multiple schemas, it may make sense to aggregate it into a single database that can be used for management and analytics - in the example above this database would have information about all of the companies in the system.

# Refactor Database Structure

In some cases, the structure of the database tables can reduce performance significantly. 

Sometimes breaking up a single table into multiple tables can help (this is known as normalizing the tables), as the original table structure may have a large number of nullable columns. 

In other cases, it may be helpful to go the other way and de-normalize tables (combine data from multiple tables into a single table). This allows data to be retrieved all at once, without requiring joins. Instead of fully denormalizing the data, it may be preferable to use a materialized view.

Working with the indexes available on database tables can also be helpful. In general we want to avoid using indexes too much when reading large amounts of data. We also want to keep in mind that indexes increase the cost for updates to the database even as they improve reads. If we occasionally read data but frequently update that data, improving the performance of the former at the expense of the latter may be a bad idea. 

# Organize Transactions into Sagas

Database transactions can have a significant impact on performance, so keeping transactions small is a good idea. 

It may be possible to break up long-running transactions into multiple transactions. What was once a single transaction becomes known as a saga. 

For example, let’s say you’re building an application that handles purchases. You can save an order in an unapproved state, and then move the order through to completion in multiple steps where each step is a separate transaction. 

With sagas, it's important to understand that the database will now have data that may later be deemed invalid - e.g. a pending order may end up not being finalized. In some cases, data that has been persisted may need to be undone at the application level rather than relying on the transaction rollback - this is known as backward recovery. Alternatively, it may be possible to fix the problems that caused the initial failure and to keep the saga going - this is called forward recovery (see [Saga Patterns](https://docs.aws.amazon.com/prescriptive-guidance/latest/cloud-design-patterns/saga.html)).

# Separate Transactional Processing from Reporting and Analytics

There is a fundamental tradeoff in database optimization when managing small transactions vs. running large reports (see [OLTP vs. OLAP](https://aws.amazon.com/compare/the-difference-between-olap-and-oltp/)). 

When running large and complex reports, it can be helpful to maintain a reporting database that can be used just for executing reports (this can be generalized to a data warehouse). In the meantime, a transactional database can continue to be used separately by the main application logic. 

A variation on this idea is to implement [CQRS](https://learn.microsoft.com/en-us/azure/architecture/patterns/cqrs), a pattern where we use one model for write operations and another one for read operations. Usually there are separate databases for reads and writes. 

In both cases, the distributed nature of the databases means that changes that occur on the write side as part of a transaction won't be visible immediately on the read side - this is known as eventual consistency (see [Eventual Consistency](https://en.wikipedia.org/wiki/Eventual_consistency)).

# Split Monolith into (Micro)services

We can take the previously mentioned idea of partitioning the database further by breaking up an application into multiple applications, each with its own database. In this case each application will communicate with the others via something like [REST](https://blog.postman.com/rest-api-examples), RPC (e.g. [gRPC](https://grpc.io)), or a message queue (e.g. [Redis](https://redis.io), [Kafka](https://kafka.apache.org/intro), or [RabbitMQ](https://www.rabbitmq.com)).

This approach offers advantages, such as more flexible development and deployment (you can develop and deploy each microservice separately). It also offers scaling benefits, since services can be orchestrated to run in different geographies, and instances of running services can be added and removed dynamically based on usage (e.g. using orchestration tools like [Docker Swarm](https://docs.docker.com/engine/swarm/key-concepts/) and [Kubernetes](https://kubernetes.io/)). 

The data for a given service can be managed more efficiently - both in terms of the amount of data and the way it is structured, since it is specific to that service.

Of course services also present many challenges. Modifying a service may cause bugs in other services that depend on it. It can also be difficult to understand the overall behaviour of the system when a workflow crosses many service boundaries Even something that sounds as simple as local testing can become more complex, as a given workflow may require deploying a variety of different services. 

There can be surprising bottlenecks as well. I find this video about Netflix's migration to microservices is still very relevant: 

{%youtube CZ3wIuvmHeM %}

With separate databases for each service, we can no longer guarantee the same type of consistency that we get with single transactions against a relational database.

All in all, my advice is to be aware of the difficulties that services present and to take a realistic and clear eyed view of the various tradeoffs involved. 

If you'd like to learn more about microservices and service-oriented architecture, I recommend reading [Monolith to Microservices](https://www.oreilly.com/library/view/monolith-to-microservices/9781492047834/), by Sam Newman.

# References
* [MapReduce](https://www.talend.com/resources/what-is-mapreduce)
* [Saga Patterns](https://docs.aws.amazon.com/prescriptive-guidance/latest/cloud-design-patterns/saga.html)
* [OLTP vs. OLAP](https://aws.amazon.com/compare/the-difference-between-olap-and-oltp)
* [CQRS](https://learn.microsoft.com/en-us/azure/architecture/patterns/cqrs)
* [Eventual Consistency](https://en.wikipedia.org/wiki/Eventual_consistency)
* [REST](https://blog.postman.com/rest-api-examples)
* [gRPC](https://grpc.io)
* [Redis](https://redis.io)
* [Kafka](https://kafka.apache.org/intro)
* [RabbitMQ](https://www.rabbitmq.com)
* [Docker Swarm](https://docs.docker.com/engine/swarm/key-concepts)
* [Kubernetes](https://kubernetes.io)
* [Mastering Chaos - A Netflix Guide to Microservices](https://www.youtube.com/watch?v=CZ3wIuvmHeM)
* [Monolith to Microservices](https://www.oreilly.com/library/view/monolith-to-microservices/9781492047834)
