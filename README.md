# Cheetah

`Cheetah` is a toy language i wrote in order to learn Pascal from [Embarcadero Delphi](https://www.embarcadero.com/es/) or [Free Pascal](https://www.freepascal.org/)

This language is based on the [MonkeyLang](https://monkeylang.org/) from [Thorsten Ball](https://github.com/mrnugget)

What is Monkey?

Monkey is a programming language that lives in these books ([Writing an Interpreter in Go](https://interpreterbook.com/) and [Writing a Compiler in Go](https://compilerbook.com/)) both from [Thorsten Ball](https://github.com/mrnugget)


The Monkey Programming Language

```Javascript
// Bind values to names with let-statements
let version = 1;
let name = "Monkey programming language";
let myArray = [1, 2, 3, 4, 5];
let coolBooleanLiteral = true;

// Use expressions to produce values
let awesomeValue = (10 / 2) * 5 + 30;
let arrayWithValues = [1 + 1, 2 * 2, 3];
```

Monkey also supports function literals and we can use them to bind a function to a name:

```Javascript
// Define a `fibonacci` function
let fibonacci = fn(x) {
  if (x == 0) {
    0                // Monkey supports implicit returning of values
  } else {
    if (x == 1) {
      return 1;      // ... and explicit return statements
    } else {
      fibonacci(x - 1) + fibonacci(x - 2); // Recursion! Yay!
    }
  }
};
```

The data types we're going to support in this book are booleans, strings, hashes, integers and arrays. We can combine them!

```Javascript
// Here is an array containing two hashes, that use strings as keys and integers
// and strings as values
let people = [{"name": "Anna", "age": 24}, {"name": "Bob", "age": 99}];

// Getting elements out of the data types is also supported.
// Here is how we can access array elements by using index expressions:
fibonacci(myArray[4]);
// => 5

// We can also access hash elements with index expressions:
let getName = fn(person) { person["name"]; };

// And here we access array elements and call a function with the element as
// argument:
getName(people[0]); // => "Anna"
getName(people[1]); // => "Bob"
```

That's not all though. Monkey has a few tricks up its sleeve. In Monkey functions are first-class citizens, they are treated like any other value. Thus we can use higher-order functions and pass functions around as values:

```Javascript
// Define the higher-order function `map`, that calls the given function `f`
// on each element in `arr` and returns an array of the produced values.
let map = fn(arr, f) {
  let iter = fn(arr, accumulated) {
    if (len(arr) == 0) {
      accumulated
    } else {
      iter(rest(arr), push(accumulated, f(first(arr))));
    }
  };

  iter(arr, []);
};

// Now let's take the `people` array and the `getName` function from above and
// use them with `map`.
map(people, getName); // => ["Anna", "Bob"]
```

And, of course, Monkey also supports closures:

```Javascript
// newGreeter returns a new function, that greets a `name` with the given
// `greeting`.
let newGreeter = fn(greeting) {
  // `puts` is a built-in function we add to the interpreter
  return fn(name) { puts(greeting + " " + name); }
};

// `hello` is a greeter function that says "Hello"
let hello = newGreeter("Hello");

// Calling it outputs the greeting:
hello("dear, future Reader!"); // => Hello dear, future Reader!
```

Monkey has a C-like syntax, supports variable bindings, prefix and infix operators, has first-class and higher-order functions, can handle closures with ease and has integers, booleans, arrays and hashes built-in.

# The Pascal implementation (Cheetah)
`Cheetah` mimics `Monkey` so there's no much to say about its features that you don't know already. My implementation is far away to be optimised and well written because this project serves as an excersize in order to learn the main features of Pascal.

# What do I think about Pascal
well, at first I was complaining a lot about having to write so many 'begin/end' everywhere but after a while my eyes got used to it and now I can say that it doesn't even bother me anymore. The syntax seems simple and pleasing to the eye, although I still have a bit of trouble reading my own code in that sea of begins/ends, so we'll see.

Regarding the speed of the compiler I must say that I am extremely surprised, it has gone over GoLang by a lot and that made me very interested in Pascal, for sure I will incorporate this language in my arsenal because I think I can create interesting tools with it. I was very surprised that the compiler has almost the same performance as C/C++/Rust.



