# Basic Aspects of a Class

## Classes and instances

Just like a string, integer or float, a class is a type, but instead of being a built-in type, classes are custom types that you define. So if a class is a new custom type, what's an object? Objects are just [instance](https://stackoverflow.com/questions/20461907/what-is-meaning-of-instance-in-programming/79673597#79673597)s of a class.

## Methods

A method is just a function that's tied directly to a class and has access to its properties. Methods are defined within the `class` declaration. Their first parameter is always the instance of the class that the method is being called on. By convention, it's called "self", and because `self` is a reference to the object, you can use it to read and update the properties of the object.

A method can operate on data that is contained within the class. For this reason they often don't return anything because they can mutate (update) the properties of the object instead.

## Constructors

To define properties on a class, a constructor can be used.  It's a specific method on a class called `__init__` that is called automatically when you create a new instance of a class. A constructor is a safe way to define properties and it also allows us to make the starting property values configurable.

**Example with NO constructor:**
```python
class Soldier:
    name = "Legolas"
    armor = 2
    num_weapons = 2

# Only possible instance is:
soldier = Soldier()
```

**Example with constructor:**
```python
class Soldier:
    def __init__(self, name, armor, num_weapons):
        self.name = name
        self.armor = armor
        self.num_weapons = num_weapons

# Instances can vary:
soldier_one = Soldier("Legolas", 2, 10)
print(soldier_one.name)
# prints "Legolas"
print(soldier_one.armor)
# prints "2"
print(soldier_one.num_weapons)
# prints "10"

soldier_two = Soldier("Gimli", 5, 1)
print(soldier_two.name)
# prints "Gimli"
print(soldier_two.armor)
# prints "5"
print(soldier_two.num_weapons)
# prints "1"
```