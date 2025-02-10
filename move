# 移动语义(move)

C++中的移动语义是引入于C++11的一种特性，它通过引入移动构造函数和移动赋值运算符，允许程序以更高效的方式管理资源，尤其是在避免不必要的拷贝操作时。

## 移动语义的定义

1移动语义的核心是利用右值引用（T&&）和标准库中的std::move，使对象的资源从一个对象转移到另一个对象，而不是拷贝，从而提高程序性能。
移动语义常见于以下场景：

1. 减少临时对象的开销（如函数返回大对象）。
2. 避免深拷贝（如容器中的数据转移）。

## 功能作用

1. 高效资源转移：避免资源分配和释放的重复工作。
2. 减少拷贝：通过转移所有权来减少对象的拷贝。
3. 提高程序性能：尤其适用于内存密集型和资源管理复杂的程序。

## 移动语义参考代码

```cpp
#include <iostream>
#include <utility> // std::move
#include <cstring> // std::strlen, std::strcpy

class MyString {
private:
    char* data;
    size_t length;

public:
    // 默认构造函数
    MyString() : data(nullptr), length(0) {}

    // 参数化构造函数
    MyString(const char* str) {
        length = std::strlen(str);
        data = new char[length + 1];
        std::strcpy(data, str);
        std::cout << "Constructed: " << data << std::endl;
    }

    // 拷贝构造函数
    MyString(const MyString& other) {
        length = other.length;
        data = new char[length + 1];
        std::strcpy(data, other.data);
        std::cout << "Copied: " << data << std::endl;
    }

    // 移动构造函数
    MyString(MyString&& other) noexcept
        : data(other.data), length(other.length) {
        other.data = nullptr;
        other.length = 0;
        std::cout << "Moved: " << data << std::endl;
    }

    // 拷贝赋值运算符
    MyString& operator=(const MyString& other) {
        if (this == &other) return *this; // 防止自赋值
        delete[] data; // 释放旧资源
        length = other.length;
        data = new char[length + 1];
        std::strcpy(data, other.data);
        std::cout << "Copy Assigned: " << data << std::endl;
        return *this;
    }

    // 移动赋值运算符
    MyString& operator=(MyString&& other) noexcept {
        if (this == &other) return *this; // 防止自赋值
        delete[] data; // 释放旧资源
        data = other.data;
        length = other.length;
        other.data = nullptr;
        other.length = 0;
        std::cout << "Move Assigned: " << data << std::endl;
        return *this;
    }

    // 析构函数
    ~MyString() {
        delete[] data;
        std::cout << "Destroyed" << (data ? ": " : ": nullptr") << (data ? data : "") << std::endl;
    }

    // 获取字符串
    const char* get() const { return data; }
};

int main() {
    MyString a("Hello");
    MyString b = a;                // 拷贝构造
    MyString c = std::move(a);     // 移动构造
    MyString d;
    d = b;                         // 拷贝赋值
    d = std::move(c);              // 移动赋值

    return 0;
}

```


## 移动语义输出结果

```cpp
Constructed: Hello
Copied: Hello
Moved: Hello
Copy Assigned: Hello
Move Assigned: Hello
Destroyed: nullptr
Destroyed: Hello
Destroyed: nullptr
Destroyed: nullptr

```

## 代码分析
### 拷贝构造函数：
1. 为新对象分配资源，并将内容复制过去。
2. 应用场景：当需要创建原对象的副本时。

### 移动构造函数：
1. 将源对象的资源指针转移到新对象，避免资源复制。
2. 设置源对象指针为nullptr以防止资源释放冲突。
3. 应用场景：当资源所有权可以转移时。
### 拷贝赋值运算符：
先释放旧资源，再深拷贝源对象的资源。
### 移动赋值运算符：
释放旧资源，转移新资源，清理源对象。
### std::move：
将左值转换为右值引用，触发移动语义。

## 关键点总结
1. 使用右值引用（T&&）定义移动构造函数和移动赋值运算符。
2. 移动语义可以避免冗余的深拷贝操作，提高程序效率。
3. 使用std::move显式启用移动语义。



## 移动语义参考代码二

```cpp
#include <iostream>
#include <utility> // std::move

class MyClass {
private:
    int* data;
    size_t size;

public:
    // 默认构造函数
    MyClass(size_t s = 0) : size(s), data(s ? new int[s] : nullptr) {
        for (size_t i = 0; i < size; ++i) {
            data[i] = i; // 初始化数据
        }
        std::cout << "Constructed MyClass of size " << size << std::endl;
    }

    // 析构函数
    ~MyClass() {
        delete[] data;
        std::cout << "Destroyed MyClass" << std::endl;
    }

    // 拷贝构造函数
    MyClass(const MyClass& other) : size(other.size), data(other.size ? new int[other.size] : nullptr) {
        for (size_t i = 0; i < size; ++i) {
            data[i] = other.data[i];
        }
        std::cout << "Copied MyClass" << std::endl;
    }

    // 移动构造函数
    MyClass(MyClass&& other) noexcept : size(other.size), data(other.data) {
        other.size = 0;
        other.data = nullptr;
        std::cout << "Moved MyClass" << std::endl;
    }

    // 拷贝赋值操作符
    MyClass& operator=(const MyClass& other) {
        if (this == &other) return *this;

        delete[] data; // 清理旧资源

        size = other.size;
        data = other.size ? new int[other.size] : nullptr;
        for (size_t i = 0; i < size; ++i) {
            data[i] = other.data[i];
        }
        std::cout << "Assigned MyClass (copy)" << std::endl;
        return *this;
    }

    // 移动赋值操作符
    MyClass& operator=(MyClass&& other) noexcept {
        if (this == &other) return *this;

        delete[] data; // 清理旧资源

        size = other.size;
        data = other.data;

        other.size = 0;
        other.data = nullptr;

        std::cout << "Assigned MyClass (move)" << std::endl;
        return *this;
    }

    // 打印内容
    void print() const {
        for (size_t i = 0; i < size; ++i) {
            std::cout << data[i] << " ";
        }
        std::cout << std::endl;
    }
};

// 测试函数
MyClass createMyClass(size_t size) {
    return MyClass(size); // 返回一个临时对象
}

int main() {
    MyClass obj1(10); // 默认构造
    obj1.print();

    MyClass obj2 = obj1; // 拷贝构造
    obj2.print();

    MyClass obj3 = createMyClass(5); // 移动构造
    obj3.print();

    obj2 = obj3; // 拷贝赋值
    obj2.print();

    obj3 = createMyClass(8); // 移动赋值
    obj3.print();

    return 0;
}

```

### 移动语义参考代码输出结果

```cpp
Constructed MyClass of size 10
0 1 2 3 4 5 6 7 8 9 
Copied MyClass
0 1 2 3 4 5 6 7 8 9 
Constructed MyClass of size 5
0 1 2 3 4 
Assigned MyClass (copy)
0 1 2 3 4 
Constructed MyClass of size 8
Assigned MyClass (move)
Destroyed MyClass
0 1 2 3 4 5 6 7 
Destroyed MyClass
Destroyed MyClass
Destroyed MyClass
```


## 代码说明：
**1. 构造函数：**
为类分配资源并初始化。

**2. 拷贝语义：**
1）拷贝构造函数：实现深拷贝，分配新的内存并复制数据。
2）拷贝赋值操作符：避免自赋值并清理旧资源。

**3. 移动语义：**
1）移动构造函数：直接转移资源，避免重复分配。
2）移动赋值操作符：释放旧资源后接管右值的资源。

**4. std::move：**
 用于显式地将一个对象转化为右值引用。
