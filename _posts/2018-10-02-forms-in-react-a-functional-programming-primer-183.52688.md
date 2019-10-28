---
title: Functional Programming with Forms in React
published: true
description: Use functional programming to start building a Formik-like framework for React forms
cover_image: /assets/images/2018-10-02-forms-in-react-a-functional-programming-primer-183.52688/vqquz2vcee7cjlzl4eyf.jpg
canonical_url: https://nestedsoftware.github.io/2018/10/02/forms-in-react-a-functional-programming-primer-183.52688.html
tags: javascript, react, functional, formik
---

Recently I was developing some forms in React. Of course I found myself copying and pasting the same bits of logic to handle input, validation, and so on in each form, so I started to think about how I could reduce the amount of code duplication.

My first idea was to put the shared logic into a base class which my form components would inherit. However, when I looked into it, I found that React tends to discourage using inheritance in this manner. 

https://reactjs.org/docs/composition-vs-inheritance.html : 

>At Facebook, we use React in thousands of components, and we haven’t found any use cases where we would recommend creating component inheritance hierarchies.
>
>Props and composition give you all the flexibility you need to customize a component’s look and behavior in an explicit and safe way. Remember that components may accept arbitrary props, including primitive values, React elements, or functions.

I thought, "okay, that's interesting. How can I use composition to extract the shared logic in my forms?" I had some ideas, but it wasn't clear to me quite how to make it all work. I did some research and ran across a nice form library for React called [Formik](https://github.com/jaredpalmer/formik).

In Formik, forms are functional components. That means they don't handle their own state directly. Instead, we write a function that takes state and some handler functions as parameters. This function returns the JSX for the form with the appropriate bindings to the parameters that were passed in. The logic and state management all happen in a Formik component that takes each functional form component as input. I also found a great [video](https://www.youtube.com/watch?v=oiNtnehlaTo) in which Jared outlines some basic scaffolding code that shows how to get started writing something like Formik. 

I went through the video and created my own version of this code with some simplifications to make things a bit more clear. 

In this article, I'll go over the basics of creating something like Formik from scratch. However, if you want to use this approach in a real application, just using the actual Formik library is probably a good idea.

Like the video, we start with a [basic form](https://reactjs.org/docs/forms.html#handling-multiple-inputs) from the React docs:

![form](/assets/images/2018-10-02-forms-in-react-a-functional-programming-primer-183.52688/c6unrz3meq7ea37mj8d7.png "Reservation Form")

```react
class Reservation extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      isGoing: true,
      numberOfGuests: 2
    };

    this.handleInputChange = this.handleInputChange.bind(this);
  }

  handleInputChange(event) {
    const target = event.target;
    const value = target.type === 'checkbox' ? target.checked : target.value;
    const name = target.name;

    this.setState({
      [name]: value
    });
  }

  render() {
    return (
      <form>
        <label>
          Is going:
          <input
            name="isGoing"
            type="checkbox"
            checked={this.state.isGoing}
            onChange={this.handleInputChange} />
        </label>
        <br />
        <label>
          Number of guests:
          <input
            name="numberOfGuests"
            type="number"
            value={this.state.numberOfGuests}
            onChange={this.handleInputChange} />
        </label>
      </form>
    );
  }
}
```

This form component manages its own state, and more importantly, it relies on some code, like `handleInputChange`, which clearly would be copied and pasted in every form.

Instead, let's extract our form into a functional component: 

```react
const ReservationForm = ({state, handleChange, handleBlur, handleSubmit}) => (
  <form onSubmit={handleSubmit}>
    <label>
      Is going:
      <input
        name="isGoing"
        type="checkbox"
        checked={state.values.isGoing}
        onChange={handleChange} 
        onBlur={handleBlur}/>
    </label>
    <br />
    <label>
      Number of guests:
      <input
        name="numberOfGuests"
        type="number"
        value={state.values.numberOfGuests}
        onChange={handleChange}
        onBlur={handleBlur}/>
    </label>
    <button>Submit</button>
    <pre>{JSON.stringify(state)}</pre>
  </form> 
)
```

There, doesn't that look better? Now our form becomes just a function that takes some parameters and returns a piece of JSX with bindings to those parameters.`ReservationForm` just returns an object based on the input it receives: It's a [pure function](https://en.wikipedia.org/wiki/Pure_function).

>This functional component still has to have parameters like `state`, `handleChange`, etc. passed directly to it. That means we need to include this boilerplate as part of every form we write. The actual Formik project supplies some standard form components which allow us to bypass having to do that.

The next question is, "how do we wire up our functional form component with the code that actually handles the form logic?" Below we simply wrap `BabyFormik` around `ReservationForm`:

```react
const ReservationFormWithBabyFormik = props => {
  const initialValues = {
    isGoing: true,
    numberOfGuests: 2,
  }
  
  const onSubmit = values => alert(JSON.stringify(values))
  
  return <BabyFormik  initialValues={initialValues} onSubmit={onSubmit}>
    <ReservationForm/>
  </BabyFormik>
}
```

We'll see how `BabyFormik` accesses `ReservationForm` next. Below is the code that contains our state management logic and communicates with the form that gets passed in:

```react
class BabyFormik extends React.Component {
  constructor(props) {
    super(props)
    
    this.handleChange = this.handleChange.bind(this)
    this.handleBlur = this.handleBlur.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)
    
    this.state = {
      values: this.props.initialValues || {},
      touched: {},
      errors: {}
    }
  }  

  handleChange(event) {    
    const target = event.target;
    const value = target.type === 'checkbox' ? target.checked : target.value;
    const name = target.name;
    
    this.setState(prevState => ({
      values: {
        ...prevState.values,
        [name]: value
      }
    }))
  }
  
  handleBlur(event) {
    const target = event.target
    const name = target.name
    this.setState(prevState => ({
      touched: {
        ...prevState.touched,
        [name]: true
      }
    }))
  }
  
  handleSubmit(event) {
    event.preventDefault()
    //add validation here 
    //set `isSubmitting` to true here as well
    this.props.onSubmit(this.state.values)
  }
  
  render() {
    //pass state and callbacks to child as parameters
    return React.cloneElement(this.props.children, {
      state: this.state,
      handleChange: this.handleChange,
      handleBlur: this.handleBlur,
      handleSubmit: this.handleSubmit
    })
  }
}
```

The `render` function passes the required variables as parameters to the child component, which in our example is `ReservationForm`.

Articles about paradigms like functional or object-oriented programming can tend to give examples that are either very abstract or too simplistic. I like this example because it shows how to use a functional approach in a practical context: We make our forms pure functions that just return JSX and we delegate the "dirty work" to a higher level component. In this example that's `BabyFormik`. That's the standard approach in functional programming: We try to write as much of the code as possible as pure functions and we fence off code that manages state or produces side effects.

Here is the full example: 

{% codepen https://codepen.io/nestedsoftware/pen/vVEjKb %}
