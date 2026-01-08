


print("Hello from PySwiftKit! in Python 🐍")
print("=" * 50)

# Import the Swift-wrapped Java CSV module
from py_java_csv import PyJavaCSV

# Sample CSV data to parse
csv_data = """Name,Age,City
Alice,30,New York
Bob,25,Los Angeles
Charlie,35,Chicago"""

print("Parsing CSV data via Python → Swift → Java:")
print("-" * 50)

# Call Swift's PyJavaCSV which calls Java's Apache Commons CSV
result = PyJavaCSV.readCSV(csv_data)
print(result)

print("=" * 50)
print("🎉 Python → Swift → Java integration complete!")


# benchmark PyJavaCSV.readCSV(csv_data) 1_000_000 times
import time

print("\n" + "=" * 50)
print("⏱️  Benchmarking Python → Swift → Java...")
print("Running 1,000 iterations...")

start = time.time()
for _ in range(1_000):
    PyJavaCSV.__readCSV(csv_data)
end = time.time()

elapsed = end - start
ops_per_sec = 1_000 / elapsed
print(f"Completed in {elapsed:.2f} seconds")
print(f"Operations/sec: {ops_per_sec:,.0f}")
print("=" * 50)


print("\n" + "=" * 50)
print("⏱️  Benchmarking list[str] → Java join string -> str...")
print("Running 1,000 iterations...")


items = ["apple", "banana", "cherry", "date", "elderberry", "fig", "grape", "honeydew", "kiwi", "lemon", "mango"]
print(PyJavaCSV.joinList(items))

start = time.time()
for _ in range(1_000):
    PyJavaCSV.joinList(items)
end = time.time()

elapsed = end - start
ops_per_sec = 1_000 / elapsed
print(f"Completed in {elapsed:.2f} seconds")
print(f"Operations/sec: {ops_per_sec:,.0f}")
print("=" * 50)