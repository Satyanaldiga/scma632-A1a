#!/usr/bin/env python
# coding: utf-8

# In[5]:


import os, pandas as pd, numpy as np


# In[6]:


os.chdir("C:\\Users\\SPURGE\\Desktop\\SCMA")


# In[7]:


df=pd.read_csv("NSSO68.csv",encoding="Latin-1", low_memory=False)


# In[8]:


df.head()


# In[13]:


MP = df[df['state_1']=="MP"]


# In[14]:


MP.isnull().sum().sort_values(ascending = False)


# In[15]:


df.columns


# In[16]:


MP_new = MP[['state_1', 'District', 'Sector','Region','State_Region','ricetotal_q','wheattotal_q','moong_q','Milktotal_q','chicken_q','bread_q','foodtotal_q','Beveragestotal_v','Meals_At_Home']]


# In[17]:


MP_new.isnull().sum().sort_values(ascending = False)


# In[18]:


MP_clean = MP_new.copy()


# In[19]:


MP_clean.loc[:, 'Meals_At_Home'] = MP_clean['Meals_At_Home'].fillna(MP_new['Meals_At_Home'].mean())


# In[20]:


MP_clean.isnull().any()


# In[21]:


# Outlier Checking
import matplotlib.pyplot as plt
# Assuming MP_clean is your DataFrame
plt.figure(figsize=(8, 6))
plt.boxplot(MP_clean['ricetotal_q'])
plt.xlabel('ricetotal_q')
plt.ylabel('Values')
plt.title('Boxplot of ricetotal_q')
plt.show()


# In[22]:


rice1 = MP_clean['ricetotal_q'].quantile(0.25)
rice2 = MP_clean['ricetotal_q'].quantile(0.75)
iqr_rice = rice2-rice1
up_limit = rice2 + 1.5*iqr_rice
low_limit = rice1 - 1.5*iqr_rice


# In[24]:


MP_clean=MP_new[(MP_new['ricetotal_q']<=up_limit)&(MP_new['ricetotal_q']>=low_limit)]


# In[25]:


plt.boxplot(MP_clean['ricetotal_q'])


# In[26]:


MP_clean['District'].unique()


# In[27]:


# Replace values in the 'Sector' column
MP_clean.loc[:,'Sector'] = MP_clean['Sector'].replace([1, 2], ['URBAN', 'RURAL'])


# In[28]:


#total consumption


# In[29]:


MP_clean.columns


# In[31]:


MP_clean.loc[:, 'total_consumption'] = MP_clean[['ricetotal_q', 'wheattotal_q', 'moong_q', 'Milktotal_q', 'chicken_q', 'bread_q', 'foodtotal_q', 'Beveragestotal_v']].sum(axis=1)


# In[32]:


MP_clean.head()


# In[33]:


MP_clean.groupby('Region').agg({'total_consumption':['std','mean','max','min']})


# In[35]:


MP_clean.groupby('District').agg({'total_consumption':['std','mean','max','min']})


# In[36]:


total_consumption_by_districtcode=MP_clean.groupby('District')['total_consumption'].sum()


# In[37]:


total_consumption_by_districtcode.sort_values(ascending=False).head(3)


# In[38]:


MP_clean.loc[:,"District"] = MP_clean.loc[:,"District"].replace({32: "Bhopal", 11: "Sagar", 26: "Indore"})


# In[39]:


total_consumption_by_districtname=MP_clean.groupby('District')['total_consumption'].sum()


# In[40]:


total_consumption_by_districtname.sort_values(ascending=False).head(3)


# In[42]:


from statsmodels.stats import weightstats as stests


# In[43]:


rural=MP_clean[MP_clean['Sector']=="RURAL"]
urban=MP_clean[MP_clean['Sector']=="URBAN"]


# In[44]:


rural.head()


# In[45]:


urban.head()


# In[47]:


cons_rural=rural['total_consumption']
cons_urban=urban['total_consumption']


# In[48]:


z_statistic, p_value = stests.ztest(cons_rural, cons_urban)
# Print the z-score and p-value
print("Z-Score:", z_statistic)
print("P-Value:", p_value)


# In[ ]:




