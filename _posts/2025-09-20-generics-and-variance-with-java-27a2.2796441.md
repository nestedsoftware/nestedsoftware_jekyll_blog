---
title: Generics and Variance with Java
published: true
description: Generics, variance and wildcards in Java
tags: java, generics, oop, variance
cover_image: /assets/images/2025-09-20-generics-and-variance-with-java-27a2.2796441/cbraadw7gav3nr6cpb2o.png
---

In this article, we’ll learn about generics in Java, with an emphasis on the concept of variance.

# Substitution of values

Let's start by introducing types and subtypes. Java supports assigning a subclass value to a variable of a base type. This is known as a widening reference assignment. We can therefore say that a Float is a subtype of a Number: 

```java
Float myFloat = Float.valueOf(3.14f);
Number number = myFloat;
```

# Arrays are covariant and reified 

Variance tells us what happens to this subtyping relationship when the original types are placed in the context of another type. 

Let's take arrays, for example. We can ask, since Float is a subtype of Number, what can we say about an array of Floats relative to an array of Numbers?

It turns out that in Java, arrays are covariant. That is, we can also assign an array of floats to an array of numbers:

```java
Float[] floats = new Float[10];
Number[] numbers = floats; //compiles due to covariance 
```

When we use the term covariant here, we mean that if a type like Float is a subtype of Number, then an array of Floats is also a subtype of an array of Numbers.

The subtyping relationship for arrays goes in the same direction as the underlying types and is therefore covariant.

Notice that in the case of Float and Number, subtyping is implemented using inheritance, but an array of Floats is also a subtype of an array of Numbers. We can say that subtyping is a more general concept than inheritance. 

The way that covariance is implemented for arrays does introduce a potential flaw into Java applications. A developer can write code to insert an object of the wrong type into the `floats` array below, yet that code will successfully compile:

```java
Float[] floats = new Float[10]; 
Number[] numbers = floats; 
Integer integer = 3; //auto-boxing
numbers[0] = integer; //compiles but not safe
```

Type information for arrays is compiled into the bytecode and is available at runtime. In fact, we can use `instanceof` as follows for arrays:

```java
Integer[] integers = new Integer[10];
Object o = integers;
if (o instanceof Float[]) { // false at runtime
    // etc...
}
```

Another way to put it is that arrays in Java are reified. Since arrays are reified, the Java runtime knows that we are trying to put an Integer into an array of Floats. When we try to actually run the line of code `numbers[0] = integer`, the application will throw an `ArrayStoreException`. 

The way covariance has been implemented for arrays in Java has a defect, but at least a buggy piece of code that tries to put the wrong type into an array will fail fast at runtime.

# Generics

## Collections before Java 5

Originally, Java did not have support for generics. These were added in Java 5. Prior to the introduction of generics, developers would have to cast to the desired type, and they would have to manually ensure that this cast was safe at runtime.

```java
List strings = new ArrayList();
strings.add(3); // compiles
String string = (String) strings.get(0); // ClassCastException at runtime
```

In Java 5, generics were introduced, and support for generics was added to the collections library as well. With generics, we can make collections typesafe:

```java
List<String> strings = new ArrayList<>();
strings.add(3); // does not compile
strings.add("hello world"); //compiles
String string = strings.get(0); //type safe, no explicit cast needed
```

## Basics of generics

A class can be parameterized to one or more generic type parameters. For example, the following `Pair` class supports creating a tuple of two arbitrary items:

```java
public class Pair<K, V> {
    private final K first;
    private final V second;

    public Pair(K first, V second) {
        this.first = first;
        this.second = second;
    }
}

Pair<String, Integer> p = new Pair<>("age", 30);
```

We can also place a base class or interface as a constraint on the upper bound for the type parameter. Additional interfaces can also be added to the bound. For example, the following `Repository` class is parameterized to a type that must be an entity, and that entity must also be serializable and comparable to other entities of the same type:

```java
class Repository <T extends Entity & Serializable & Comparable<T>> {
    // etc...
}
```

## Recursive type bounds

As we can see in the previous example, type parameters are occasionally defined recursively, i.e. our type `T` was supplied as a parameter to `Comparable`. 

In the following example, we create our own interface, similar to Java’s `Comparable`. Rather than allowing the `compareTo` method to apply to any arbitrary type, here we arrange for `MyComparable` to apply to the specific class or interface that implements our `MyComparable` interface:

```java
public interface MyComparable<T extends MyComparable<T>> {
    int compareTo(T other);
}

public class MyInteger implements MyComparable<MyInteger> {
    public int compareTo(MyInteger otherInteger) {
        // ...
    }
}

public class MyFloat implements MyComparable<MyFloat> {
    public int compareTo(MyFloat otherFloat) {
        // ...
    }
}
```

This pattern is sometimes used for builders, to support a fluent interface for a subclassed builder, such that it can return itself to continue chaining calls. It's also used behind the scenes for Java enums:

```java
//from openjdk source code
public abstract class Enum<E extends Enum<E>> implements Constable, Comparable<E>, Serializable {
    // ...
}

public enum MyEnum {
    VAL1,
    VAL2
}

// it's not legal to write code like this, but MyEnum does extend Enum<MyEnum>
public class MyEnum extends Enum<MyEnum> { 
    // ...
}
```
## Generic type parameters for methods

Generic type parameters can also be applied directly to a method declaration:

```java
public static <T> T firstElement(List<T> items) {
    return items.get(0);
}
```

As with classes, we can define upper bounds for the type parameters for methods:

```java
public static <T extends MyService & Closeable> MyResourceWrapper<T> of(T input) {
    // etc...
}
```

## Generic type parameters are invariant and not reified

Unlike arrays, generics are not covariant - they are invariant. For example, the following will not compile:

```java
List<Number> numbers = new ArrayList<Integer>(); // does not compile
```

This means that while an Integer is a subtype of Number, a list of Integers is not a subtype of a list of Numbers. If this were allowed in the same way as it is with arrays, we could introduce the wrong type of object, such as a Float, into the list, and the code would still compile.

However, with generics the problem would be worse. Unlike arrays, the type information supplied via generics is not available at runtime. This is called type erasure. In general, we cannot do the following:

```java
if (someObject instanceof List<String> strings) {
    // etc...
}
```

The best we could do is something like this:

```java
if (o instanceof List<?> someList) {
    // etc...
}
```

When generics were introduced in Java 5, the designers decided not to include the type information for objects with generic type parameters in the bytecode, in order to  maintain backward compatibility with older versions of Java. 

Therefore, unlike arrays, generics are not reified. Behind the scenes, the compiled bytecode still casts to the desired type. It's just that this casting is deemed safe given that the code has been compiled successfully. This remains the case in modern Java.

Because generics are not reified, the runtime doesn't associate an instance of a collection with any particular type. If collections were covariant, that means we could successfully insert the wrong type of object into a collection at runtime, and we would only get a runtime error at some point in the future, when we tried to use that object later on. 

When the wrong type of object is successfully introduced at runtime like this, it's called heap pollution. Heap pollution can still occur in Java in a number of ways, e.g. when mixing generics with arrays and varargs. It can happen if the developer makes unsafe casts or uses raw collections, or via reflection as well. However, for the most part, generics help us to make our Java code typesafe.

## Variance and PECS

While generic type parameters are invariant, there is support for variance with generics in the form of wildcard type parameters. A well known acronym, PECS, which stands for "producer extends, consumer super" is often used as a mnemonic when thinking about variance. We will go into more detail to explain variance and this acronym below.

### Covariance

Wildcard type parameters cannot be used as part of a generic type declaration. That is to say, in Java, variance for generics is expressed at the use site.

The following is an example of a wildcard type parameter being used for a variable declaration:

```java
List<? extends Number> numbers = new ArrayList<Float>();
numbers = new ArrayList<Integer>();
```

In the above code, we can say that a list of Integers or Floats is a subtype of a list of covariant Numbers. 

Why is this useful? Let's say we've written a class `MyStack` which offers standard stack operations like `push` and `pop`. Now we wish to add a `pushAll` method which allows us to push multiple items at a time onto our stack. We could try something like this:

```java
public class MyStack<T> {
    // other methods like push, pop, etc. not shown

    public void pushAll(List<T> items) {
        for (T item : items) {
            push(item);
        }
    }
}
```

However, this means that if we have a stack of Numbers, we cannot push the items from a stack of Integers onto our stack, since generics are invariant:

```java
List<Integer> integers = List.of(1, 2, 3);
MyStack<Number> numbers = new MyStack<>();
numbers.pushAll(integers); // does not compile
```

In principle, there is no harm in having integers on our stack, but the compiler cannot allow a `List<Integer>` where a `List<Number`> is expected, because this could cause heap pollution, as mentioned earlier.

We can solve this problem with covariance:

```java
public class MyStack<T> {
    // other methods like push, pop, etc. not shown

    public void pushAll(List<? extends T> items) {
        for (T item : items) {
            push(item);
        }
    }
}
```

Covariance with wildcards also lets us write code along the following lines:

```java
public static <T> List<T> combine(List<? extends List <? extends T>> listOfLists) {
    // etc...
}
```
In the above code, we are able to combine the supplied lists together, regardless of how many different subclasses of type `<T>` there may be.

To prevent the issues that covariant arrays have, the compiler imposes a restriction on how wildcards can be used. In the case of the `pushAll` method, the compiler knows every individual item in `items` must be a number, so pushing onto our stack is typesafe. 

However, we don't know what is actually passed in - it could be a `List<Number>`, a `List<Integer>`, a `List<Float`, etc. Because of this, the following code doesn't compile:

```java
public static double averageOrDefault(List<? extends Number>numbers) {
    if (numbers.isEmpty()) {
        numbers.add(0); // does not compile
    }
    return average(numbers);
}
```

The reason is that we could call this method with `List<Integer>` but also with some other lists of Numbers:

```java
List<Integer> integers = new ArrayList<>();
averageOrDefault(integers); // compiles

List<Float> floats = new ArrayList<>();
averageOrDefault(floats); // compiles

List<Number> numbers = new ArrayList<>();
averageOrDefault(numbers); // also compiles
```

With a covariant generic type, `null` is the only valid argument that can be passed in to such a method, since `null` isn't specific to any particular type.

That's the reason for the "producer extends" part of PECS. When we use covariance, we know any items we obtain will have the desired upper bound, but the compiler can't know for sure what the exact type is. We know that the producer can supply us with an instance that is a subtype of the upper bound on the type parameter, but we don't know which one, so the most specific we can get is to assign values to variables typed to the upper bound. Covariance is therefore used when we want to, in some sense, get items out. Hence we think of covariant generics as producers.

### Contravariance

Now we want to implement a `popAll` method for `MyStack`, which pops all items from our stack and adds them to the supplied list:

```java
public class MyStack<T> {
    // other methods like push, pop, etc. not shown

    public void popAll(List<T> items) {
        while (!isEmpty()) {
            T popped = pop();
            items.add(popped);
        }
    }
}
```

The following won't compile:

```java
List<Object> anything = new ArrayList<>();
MyStack<Integer> integers = new MyStack<>();
integers.push(1);
integers.push(2);
integers.push(3);
integers.popAll(anything);
```

Even though we can see that it's safe to add integers to a list of objects, the compiler won't allow this code to compile because generics are invariant. However, we can fix this by making the argument contravariant:

```java
public class MyStack<T> {
    // other methods like push, pop, etc. not shown

    public void popAll(List<? super T> items) {
        while (!isEmpty()) {
            T popped = pop();
            items.add(popped);
        }
    }
}
```

Now our code below will compile:

```java
List<Object> anything = new ArrayList<>();

MyStack<Integer> integers = new MyStack<>();
integers.push(1);
integers.push(2);
integers.push(3);

integers.popAll(anything); // compiles

List<Number> numbers = new ArrayList<>();
integers.popAll(numbers); // also compiles

List<Integer> moreIntegers = new ArrayList<>();
integers.popAll(moreIntegers); // also compiles - super is inclusive
```

However, the following won't compile:

```java
List<Float> floats = new ArrayList<>();
integers.popAll(floats); // does not compile!
```

Here we can see that contravariance allows us to safely feed items into the list, as long the type of object passed in is a subtype of the lower bound specified for the argument to the method being called. 

However, since we don't know precisely what type of list was passed in, if we want to call a method that returns an item from that list, all we can do is assign that item to `Object`:

```java
List<Object> items= new ArrayList<>();
items.add("hello");

List<? super Number> contravariantNumbers = items;
items.add(3.14); // can add any subtype of number
for(Object o : contravariantNumbers) { //can only get Objects though
    System.out.println("o = " + o); 
}
```

Here we can say that a list of Objects is a subtype of a contravariant list of Numbers, so the variance goes in the opposite direction from Number being a subtype of Object, hence the "contra" in contravariance. That's why the following assignment makes sense:

```java
List<? super Number> contravariantNumbers = new ArrayList<Object>();
```

We can see that this is a mirror image of the situation with covariance. That's why contravariant types are thought of as consumers, i.e. the "consumer super" in PECS. With a contravariant type, we think about supplying items to it in some sense, hence it is a consumer. 

### Invariance with unbounded wildcards

We can also specify an unbounded wildcard:

```java
List<?> arbitraryList = new ArrayList<Integer>();
```

This is useful when we don't care about the type of object. When specifying an unbounded wildcard, as with covariance we can't supply an argument other than null to methods that take parameters of the type that the class or method was parameterized to. Also, we can only assign the type parameterized values returned from methods to Object, as with contravariance. In this scenario, there a single specific type, so the code is still typesafe, but it doesn’t matter what it is.

Below are some examples where such wildcards make sense:

```java
public boolean containsAll(Collection<?> c) {
    // etc...
}

public static int size(Iterable<?> iterable) {
    // etc...
}
```

### Combining covariance and contravariance together

The following example pulls covariance and contravariance for generics together. We copy all of the items from `source` into `destination`.

```java
public static <T> void copy(List<? super T> destination, List<? extends T> source) {
    for (T item : source) {
        destination.add(item);
    }
}

List<Integer> integers = List.of(1, 2, 3);
List<Number> numbers = new ArrayList<>();
copy(numbers, integers); // variance allows the types of the two arguments to be different
```

Let's consider how the compiler treats type `T` in the above example. We pass in `integers` as the source, so we can infer that for this particular call, `Integer` must extend `T`. We pass in `numbers` as the destination, so `Number` must be a base type of `T`. Therefore, for this scenario, `T` must be `Number`. 

If we passed in a `List<Float>` as the destination, the code would not compile, since `T` would have to extend `Integer`. If we passed in `List<Object>` as the source, that also would not compile, since `T` must extend `Number`. 

In this case, if the source is `List<Integer>`, then destination must be one of `List<Object>`, `List<Number>`, or `List<Integer>`:

```java
List<Object> objects = new ArrayList<>();
copy(objects, integers);

List<Number> numbers = new ArrayList<>(List.of(1, 3.14, new BigDecimal("50.500"));
copy(numbers, integers);

List<Integer> moreIntegers = new ArrayList<>(List.of(1, 2, 3));
copy(moreIntegers, integers);
```

We could also pass in variables with wildcards:

```java
List<? extends Number> covariantNumbers = integers;
List<? super Number> contravariantNumbers = objects;
copy(contravariantNumbers, covariantNumbers);
```
### Declaration vs. use-site variance

As we have seen, in Java, variance for generics can only be expressed at the use site via wildcards (e.g., `List<? extends T>`, `List<? super T>`). We cannot make a generic type parameter for a class or method covariant or contravariant. 

In another JVM language, Scala, we can actually specify variance at the declaration site, i.e. the declaration of the type parameter itself. 

In the code below, `Box` is covariant in T, i.e., `+T`. The compiler enforces type safety for all of its methods, without wildcards. Returning `T` is allowed, but accepting a `T` as a parameter is not:

```scala
class Box[+T](private var value: T) {
    def get: T = value // compiles, T in covariant (return) position
    def set(newValue: T): Unit = {
      value = newValue // does not compile, covariant type T appears in contravariant position
    }
    override def toString: String = s"Box($value)"
}

object VarianceDemo extends App {
    val intBox: Box[Integer] = new Box[Integer](Integer.valueOf(123))
    val numberBox: Box[Number] = intBox // compiles Integer is a subtype of Number, and Box is covariant

    println(intBox.get) // 123
    println(numberBox.get) // 123 as a Number

    def printNumber(box: Box[Number]): Unit =
        println(s"Number inside: ${box.get}")

    printNumber(intBox) // compiles due to covariance
}
```

### Type capture

Consider the following `swap` method. We don't really need to specify the type parameter for this method, since we are re-organizing items that are already in the collection. Therefore it makes sense to use an unbounded wildcard:
```java
public static void swap(List<?> list, int i, int j) {
    list.set(i, list.set(j, list.get(i))); // does not compile
}
```

This does pose a problem though. We can't get an item out of this list except as an Object, and that means we can't safely put that item back into the list at a different location. Whenever we use a wildcard like this, behind the scenes, Java assigns the type as an arbitrary synthetic type, such as `CAP#1`. It doesn't matter what this is exactly. We can write a utility method that binds this synthetic type to a type parameter. This is called capture conversion:

```java
public static void swap(List<?> list, int i, int j) {
    swapCapture(list, i, j);
}
private static <T> void swapCapture(List<T> list, int i, int j) {
    T temp = list.get(i);
    list.set(i, list.get(j));
    list.set(j, temp);

    // we could also implement this more concisely as follows
    // list.set(i, list.set(j, list.get(i)));
}
```

As we can see, the above code allows us to use a well-defined `temp` variable so that we can swap the items in a typesafe manner.

We could declare the `swap` method with the type parameter `<T>` in the first place, avoiding the wildcards entirely. However, from an API design point of view, it is cleaner to use the wildcard here. If we are not referring to the same type in multiple places, it is a good practice to use wildcards.

### Do not return variables with wildcards

While using wildcards for method parameters is appropriate, it is not generally a good practice for the return type to use a wildcard.

This limits what the client can do, and makes it harder to chain methods that don't expect wildcards. Variance should be something that adds flexibility to an API while maintaining type safety, but it should not be an unnecessary burden on the developer using that API.

### Additional examples

In the following example, the `max` method returns the largest value from the supplied collection:

```java
public static <T extends Object & Comparable<? super T>> T max(Collection<? extends T> coll) {
 // ...
}
```

It makes sense to use a contravariant type for `Comparable<? super T>`, since we don't want to force `<T>` itself to implement the Comparable interface directly. One of its base classes or interfaces could do that instead.

Similarly, the `sort` method below also takes a `Comparator<? super T>`. We could pass in a list of integers as `list` and a `Comparator<Number>` or `Comparator<Object>`. Both of these comparators can safely consume an Integer.

```java
public static <T> void sort(List<T> list, Comparator<? super T> c) {
 // ...
}
```

In the following example from the `Optional` class, the `map` method takes a function that will be applied to the object already stored in the Optional. This function will be contravariant with respect to its argument and covariant with respect to its return values:

```java
public final class Optional<T> { 
    public <U> Optional<U> map(Function<? super T, ? extends U> mapper) {
        Objects.requireNonNull(mapper);
        if (!isPresent()) {
            return empty();
        } else {
            return Optional.ofNullable(mapper.apply(value));
        }
    }  
}
```
The following makes sense for this use-case:

```java
Function<Number, String> mapper = (num) -> num.toString();
Optional<Integer> optionalInt = Optional.of(3);
Optional<CharSequence> optionalChars = optionalInt.map(mapper);
```

In the above code, we can pass in any Number to our `mapper` function, so passing in an Integer is fine. We can also return any subtype of String, so assigning to a base type such as CharSequence is also fine.

# References

* [Effective Java, by Joshua Bloch (Chapter 5, Generics)](https://www.oreilly.com/library/view/effective-java-3rd/9780134686097/)
* [OpenJDK source code](https://github.com/openjdk/)
* [Guava source code](https://github.com/google/guava)
* [Palantir delegate processors source code](https://github.com/palantir/delegate-processors)
*[Variance in Scala](https://docs.scala-lang.org/tour/variances.html)
