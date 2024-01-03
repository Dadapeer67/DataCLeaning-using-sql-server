select *
From [sql cleaning]..Sheet1$

--STANDARLIZE DATA

select SaleDateConverted,CONVERT(date,SaleDate)
From [sql cleaning]..Sheet1$

update dbo.Sheet1$
set SaleDate=CONVERT(date,SaleDate)

ALTER TABLE  dbo.Sheet1$
Add SaleDateConverted Date;

update dbo.Sheet1$
set SaleDateConverted=CONVERT(date,SaleDate)

--PROPERTY ADDRESS

select *
From [sql cleaning]..Sheet1$
--WHERE PropertyAddress is NULL
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
From [sql cleaning]..Sheet1$ a
join [sql cleaning]..Sheet1$ b
on a.ParcelID=b.ParcelID
and  a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is NULL

update a
set PropertyAddress =ISNULL(a.PropertyAddress,b.PropertyAddress)
From [sql cleaning]..Sheet1$ a
join [sql cleaning]..Sheet1$ b
on a.ParcelID=b.ParcelID
and  a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is NULL

--BREAKING OUT THE ADDRESS

select PropertyAddress
From [sql cleaning]..Sheet1$
--WHERE PropertyAddress is NULL
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
from [sql cleaning]..Sheet1$


ALTER TABLE  dbo.Sheet1$
Add PropertySplitAddress Nvarchar(255);

update dbo.Sheet1$
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 


ALTER TABLE  dbo.Sheet1$
Add PropertySplitCity  Nvarchar(255);

update dbo.Sheet1$
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) 

Select *
from [sql cleaning]..Sheet1$



Select OwnerAddress
From [sql cleaning]..Sheet1$

Select 
 PARSENAME(REPLACE(OwnerAddress,',','.'),3)
 ,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
 ,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From [sql cleaning]..Sheet1$

ALTER TABLE  dbo.Sheet1$
Add OwnerSplitAddress Nvarchar(255);

update dbo.Sheet1$
set OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE  dbo.Sheet1$
Add OwnerSplitCity  Nvarchar(255);

update dbo.Sheet1$
set OwnerSplitCity =PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE  dbo.Sheet1$
Add OwnerSplitState  Nvarchar(255);

update dbo.Sheet1$
set OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From [sql cleaning]..Sheet1$

----CHANGE Y AND N FROM TO YES AND NO FROM SOLD AS VACANT FEILD

Select Distinct(SoldAsVacant) ,COUNT(SoldAsVacant)
From [sql cleaning]..Sheet1$
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
,CASE WHEN SoldAsVacant='Y' THEN 'YES'
  WHEN SoldAsVacant='N' THEN 'NO'
  ELSE SoldAsVacant
  END
From [sql cleaning]..Sheet1$

UPDATE Sheet1$
SET SoldAsVacant=CASE WHEN SoldAsVacant='Y' THEN 'YES'
  WHEN SoldAsVacant='N' THEN 'NO'
  ELSE SoldAsVacant
  END


  ----REMOVE DUPLICATES

  WITH ROW_NUMCTE AS (
  SELECT *, 
   ROW_NUMBER () OVER (
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				   UniqueID
				  )ROW_NUM
FROM [sql cleaning]..Sheet1$
--order by ParcelID
)
DELETE 
FROM ROW_NUMCTE
WHERE ROW_NUM>1
--Order by PropertyAddress


--NOW CHECK DUPLICATES ARE DELETED

 WITH ROW_NUMCTE AS (
  SELECT *, 
   ROW_NUMBER () OVER (
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				   UniqueID
				  )ROW_NUM
FROM [sql cleaning]..Sheet1$
--order by ParcelID
)
SELECT * 
FROM ROW_NUMCTE
WHERE ROW_NUM>1
--Order by PropertyAddress
   


   --DELETE UNUSED COLUMNS


  Select *
From [sql cleaning]..Sheet1$

ALTER TABLE  [sql cleaning]..Sheet1$
DROP COLUMN  OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE  [sql cleaning]..Sheet1$
DROP COLUMN  SaleDate
